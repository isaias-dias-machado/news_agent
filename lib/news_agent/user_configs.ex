defmodule NewsAgent.UserConfigs do
  @moduledoc """
  Boundary for persisting user configuration records.

  Contract: callers create, fetch, list, and update user configs by integer id,
  with each record stored in the append-only storage and a monotonically
  increasing id assigned at creation time. Callers should treat the returned
  records as the source of truth for chat linkage and URL sources.

  Tensions: storage writes are serialized through this process for atomic id
  assignment, and persistence depends on the underlying filesystem durability
  guarantees of the storage layer.
  """

  use GenServer

  alias NewsAgent.Storage

  @type record :: %{
          id: pos_integer(),
          chat_id: String.t() | nil,
          url_sources: [String.t()],
          schema_version: 1
        }

  @type option ::
          {:dir, String.t()}
          | {:storage_name, atom()}
          | {:name, atom() | {:global, term()} | {:via, module(), term()}}

  @next_id_key "__next_id__"
  @ids_key "__ids__"
  @schema_version 1

  @doc """
  Starts the UserConfigs process.
  """
  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Creates a user config with optional chat id and URL sources.
  """
  @spec create(map()) :: {:ok, record()} | {:error, term()}
  def create(attrs \\ %{}) when is_map(attrs) do
    GenServer.call(__MODULE__, {:create, attrs})
  end

  @doc """
  Creates a user config with the given chat id and URL sources.
  """
  @spec create(String.t() | nil, [String.t()]) :: {:ok, record()} | {:error, term()}
  def create(chat_id, url_sources) when is_list(url_sources) do
    create(%{chat_id: chat_id, url_sources: url_sources})
  end

  @doc """
  Fetches a user config by id.
  """
  @spec get(pos_integer()) :: {:ok, record()} | :error
  def get(id) when is_integer(id) and id > 0 do
    GenServer.call(__MODULE__, {:get, id})
  end

  @doc """
  Lists all user configs.
  """
  @spec list() :: [record()]
  def list do
    GenServer.call(__MODULE__, :list)
  end

  @doc """
  Finds a user config by chat id.
  """
  @spec find_by_chat_id(String.t()) :: {:ok, record()} | :error
  def find_by_chat_id(chat_id) when is_binary(chat_id) do
    GenServer.call(__MODULE__, {:find_by_chat_id, chat_id})
  end

  @doc """
  Updates a user config with the given attributes.
  """
  @spec update(pos_integer(), map()) :: {:ok, record()} | {:error, term()}
  def update(id, attrs) when is_integer(id) and id > 0 and is_map(attrs) do
    GenServer.call(__MODULE__, {:update, id, attrs})
  end

  @doc """
  Deletes a user config by id.
  """
  @spec delete(pos_integer()) :: :ok | {:error, term()}
  def delete(id) when is_integer(id) and id > 0 do
    GenServer.call(__MODULE__, {:delete, id})
  end

  @doc """
  Clears all user configs and resets stored metadata.
  """
  @spec clear_all() :: :ok
  def clear_all do
    GenServer.call(__MODULE__, :clear_all)
  end

  @impl true
  def init(opts) do
    dir = Keyword.get(opts, :dir, "data/user_configs")
    storage_name = Keyword.get(opts, :storage_name, storage_name())
    {:ok, storage} = Storage.start_link(dir: dir, name: storage_name)
    :ok = ensure_metadata(storage)
    {:ok, %{storage: storage}}
  end

  @impl true
  def handle_call({:create, attrs}, _from, state) do
    with {:ok, chat_id, url_sources} <- validate_attrs(attrs) do
      id = next_id(state.storage)
      record = build_record(id, chat_id, url_sources)
      :ok = Storage.put(state.storage, record_key(id), encode_record(record))
      :ok = Storage.put(state.storage, @ids_key, append_id(state.storage, id))
      :ok = Storage.put(state.storage, @next_id_key, id + 1)
      {:reply, {:ok, record}, state}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:get, id}, _from, state) do
    reply =
      case Storage.get(state.storage, record_key(id)) do
        {:ok, data} -> decode_record(data)
        :error -> :error
      end

    case reply do
      %{} = record -> {:reply, {:ok, record}, state}
      :error -> {:reply, :error, state}
    end
  end

  def handle_call(:list, _from, state) do
    records =
      state.storage
      |> ids()
      |> Enum.sort()
      |> Enum.flat_map(fn id ->
        case Storage.get(state.storage, record_key(id)) do
          {:ok, data} ->
            case decode_record(data) do
              %{} = record -> [record]
              :error -> []
            end

          :error ->
            []
        end
      end)

    {:reply, records, state}
  end

  def handle_call({:find_by_chat_id, chat_id}, _from, state) do
    record =
      state.storage
      |> ids()
      |> Enum.flat_map(fn id ->
        case Storage.get(state.storage, record_key(id)) do
          {:ok, data} ->
            case decode_record(data) do
              %{} = record -> [record]
              :error -> []
            end

          :error ->
            []
        end
      end)
      |> Enum.find(fn record -> record.chat_id == chat_id end)

    case record do
      nil -> {:reply, :error, state}
      %{} = record -> {:reply, {:ok, record}, state}
    end
  end

  def handle_call({:update, id, attrs}, _from, state) do
    case Storage.get(state.storage, record_key(id)) do
      {:ok, data} ->
        with %{} = record <- decode_record(data),
             {:ok, chat_id, url_sources} <- merge_attrs(record, attrs) do
          updated = build_record(id, chat_id, url_sources)
          :ok = Storage.put(state.storage, record_key(id), encode_record(updated))
          {:reply, {:ok, updated}, state}
        else
          :error -> {:reply, {:error, :invalid_record}, state}
          {:error, reason} -> {:reply, {:error, reason}, state}
        end

      :error ->
        {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:delete, id}, _from, state) do
    case Storage.get(state.storage, record_key(id)) do
      {:ok, _data} ->
        :ok = Storage.delete(state.storage, record_key(id))
        :ok = Storage.put(state.storage, @ids_key, remove_id(state.storage, id))
        {:reply, :ok, state}

      :error ->
        {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call(:clear_all, _from, state) do
    state.storage
    |> ids()
    |> Enum.each(fn id ->
      :ok = Storage.delete(state.storage, record_key(id))
    end)

    :ok = Storage.put(state.storage, @ids_key, [])
    :ok = Storage.put(state.storage, @next_id_key, 1)

    {:reply, :ok, state}
  end

  defp ensure_metadata(storage) do
    case Storage.get(storage, @next_id_key) do
      {:ok, _} -> :ok
      :error -> Storage.put(storage, @next_id_key, 1)
    end

    case Storage.get(storage, @ids_key) do
      {:ok, _} -> :ok
      :error -> Storage.put(storage, @ids_key, [])
    end
  end

  defp next_id(storage) do
    case Storage.get(storage, @next_id_key) do
      {:ok, value} when is_integer(value) and value > 0 -> value
      _ -> 1
    end
  end

  defp ids(storage) do
    case Storage.get(storage, @ids_key) do
      {:ok, value} when is_list(value) -> Enum.filter(value, &is_integer/1)
      _ -> []
    end
  end

  defp append_id(storage, id) do
    storage
    |> ids()
    |> Enum.reject(&(&1 == id))
    |> Kernel.++([id])
  end

  defp remove_id(storage, id) do
    storage
    |> ids()
    |> Enum.reject(&(&1 == id))
  end

  defp validate_attrs(attrs) do
    chat_id = fetch_attr(attrs, :chat_id)
    url_sources = fetch_attr(attrs, :url_sources)

    with {:ok, chat_id} <- validate_chat_id(chat_id),
         {:ok, url_sources} <- validate_url_sources(url_sources) do
      {:ok, chat_id, url_sources}
    end
  end

  defp merge_attrs(record, attrs) do
    chat_id =
      case Map.has_key?(attrs, :chat_id) or Map.has_key?(attrs, "chat_id") do
        true -> fetch_attr(attrs, :chat_id)
        false -> record.chat_id
      end

    url_sources =
      case Map.has_key?(attrs, :url_sources) or Map.has_key?(attrs, "url_sources") do
        true -> fetch_attr(attrs, :url_sources)
        false -> record.url_sources
      end

    with {:ok, chat_id} <- validate_chat_id(chat_id),
         {:ok, url_sources} <- validate_url_sources(url_sources) do
      {:ok, chat_id, url_sources}
    end
  end

  defp fetch_attr(attrs, key) do
    Map.get(attrs, key, Map.get(attrs, Atom.to_string(key)))
  end

  defp validate_chat_id(nil), do: {:ok, nil}

  defp validate_chat_id(chat_id) when is_binary(chat_id) do
    {:ok, chat_id}
  end

  defp validate_chat_id(_value), do: {:error, :invalid_chat_id}

  defp validate_url_sources(nil), do: {:ok, []}

  defp validate_url_sources(value) when is_list(value) do
    if Enum.all?(value, &is_binary/1) do
      {:ok, value}
    else
      {:error, :invalid_url_sources}
    end
  end

  defp validate_url_sources(_value), do: {:error, :invalid_url_sources}

  defp build_record(id, chat_id, url_sources) do
    %{
      id: id,
      chat_id: chat_id,
      url_sources: url_sources,
      schema_version: @schema_version
    }
  end

  defp encode_record(record) do
    %{
      "id" => record.id,
      "chat_id" => record.chat_id,
      "url_sources" => record.url_sources,
      "schema_version" => record.schema_version
    }
  end

  defp decode_record(data) when is_map(data) do
    id = Map.get(data, "id") || Map.get(data, :id)
    chat_id = Map.get(data, "chat_id") || Map.get(data, :chat_id)
    url_sources = Map.get(data, "url_sources") || Map.get(data, :url_sources)
    schema_version = Map.get(data, "schema_version") || Map.get(data, :schema_version)

    with {:ok, id} <- validate_id(id),
         {:ok, chat_id} <- validate_chat_id(chat_id),
         {:ok, url_sources} <- validate_url_sources(url_sources),
         true <- schema_version == @schema_version do
      %{
        id: id,
        chat_id: chat_id,
        url_sources: url_sources,
        schema_version: @schema_version
      }
    else
      _ -> :error
    end
  end

  defp decode_record(_data), do: :error

  defp validate_id(id) when is_integer(id) and id > 0, do: {:ok, id}
  defp validate_id(_id), do: {:error, :invalid_id}

  defp record_key(id), do: Integer.to_string(id)
  defp storage_name, do: Module.concat(__MODULE__, Storage)
end
