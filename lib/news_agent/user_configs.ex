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

  @type due_time :: {hour :: 0..23, minute :: 0..59} | nil

  @type record :: %{
          id: pos_integer(),
          chat_id: String.t() | nil,
          url_sources: [String.t()],
          due_time: due_time(),
          last_date: String.t() | nil,
          status: :success | :cutoff_reached | nil,
          last_run_at: String.t() | nil,
          schema_version: 2
        }

  @type option ::
          {:dir, String.t()}
          | {:storage_name, atom()}
          | {:name, atom() | {:global, term()} | {:via, module(), term()}}

  @next_id_key "__next_id__"
  @ids_key "__ids__"
  @schema_version 2

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
  Updates scheduler fields for a user config.
  """
  @spec update_scheduler(pos_integer(), map()) :: {:ok, record()} | {:error, term()}
  def update_scheduler(id, attrs) when is_integer(id) and id > 0 and is_map(attrs) do
    GenServer.call(__MODULE__, {:update_scheduler, id, attrs})
  end

  @doc """
  Sets the scheduler delivery due time for a user config.
  """
  @spec set_due_time(pos_integer(), due_time()) :: {:ok, record()} | {:error, term()}
  def set_due_time(id, due_time) when is_integer(id) and id > 0 do
    update_scheduler(id, %{due_time: due_time})
  end

  @doc """
  Sets the scheduler last finalized date for a user config.
  """
  @spec set_last_date(pos_integer(), String.t() | nil) :: {:ok, record()} | {:error, term()}
  def set_last_date(id, last_date) when is_integer(id) and id > 0 do
    update_scheduler(id, %{last_date: last_date})
  end

  @doc """
  Sets the scheduler status for a user config.
  """
  @spec set_status(pos_integer(), :success | :cutoff_reached | nil) :: {:ok, record()} | {:error, term()}
  def set_status(id, status) when is_integer(id) and id > 0 do
    update_scheduler(id, %{status: status})
  end

  @doc """
  Sets the scheduler last run timestamp for a user config.
  """
  @spec set_last_run_at(pos_integer(), DateTime.t() | String.t() | nil) ::
          {:ok, record()} | {:error, term()}
  def set_last_run_at(id, last_run_at) when is_integer(id) and id > 0 do
    update_scheduler(id, %{last_run_at: last_run_at})
  end

  @doc """
  Lists all user configs for scheduler planning.
  """
  @spec list_for_scheduler() :: [record()]
  def list_for_scheduler do
    GenServer.call(__MODULE__, :list_for_scheduler)
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
    {:reply, list_records(state.storage), state}
  end

  def handle_call(:list_for_scheduler, _from, state) do
    {:reply, list_records(state.storage), state}
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
          updated =
            build_record(id, chat_id, url_sources, %{
              due_time: record.due_time,
              last_date: record.last_date,
              status: record.status,
              last_run_at: record.last_run_at
            })

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

  def handle_call({:update_scheduler, id, attrs}, _from, state) do
    case Storage.get(state.storage, record_key(id)) do
      {:ok, data} ->
        with %{} = record <- decode_record(data),
             {:ok, scheduler_fields} <- merge_scheduler_attrs(record, attrs) do
          updated =
            build_record(id, record.chat_id, record.url_sources, scheduler_fields)

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

  defp build_record(id, chat_id, url_sources, scheduler_fields \\ %{}) do
    %{
      id: id,
      chat_id: chat_id,
      url_sources: url_sources,
      due_time: Map.get(scheduler_fields, :due_time),
      last_date: Map.get(scheduler_fields, :last_date),
      status: Map.get(scheduler_fields, :status),
      last_run_at: Map.get(scheduler_fields, :last_run_at),
      schema_version: @schema_version
    }
  end

  defp encode_record(record) do
    %{
      "id" => record.id,
      "chat_id" => record.chat_id,
      "url_sources" => record.url_sources,
      "due_time" => encode_due_time(record.due_time),
      "last_date" => record.last_date,
      "status" => encode_status(record.status),
      "last_run_at" => encode_last_run_at(record.last_run_at),
      "schema_version" => record.schema_version
    }
  end

  defp decode_record(data) when is_map(data) do
    id = Map.get(data, "id") || Map.get(data, :id)
    chat_id = Map.get(data, "chat_id") || Map.get(data, :chat_id)
    url_sources = Map.get(data, "url_sources") || Map.get(data, :url_sources)
    due_time = Map.get(data, "due_time") || Map.get(data, :due_time)
    last_date = Map.get(data, "last_date") || Map.get(data, :last_date)
    status = Map.get(data, "status") || Map.get(data, :status)
    last_run_at = Map.get(data, "last_run_at") || Map.get(data, :last_run_at)
    schema_version = Map.get(data, "schema_version") || Map.get(data, :schema_version)

    with {:ok, id} <- validate_id(id),
         {:ok, chat_id} <- validate_chat_id(chat_id),
         {:ok, url_sources} <- validate_url_sources(url_sources),
         {:ok, due_time} <- validate_due_time(due_time),
         {:ok, last_date} <- validate_last_date(last_date),
         {:ok, status} <- validate_status(status),
         {:ok, last_run_at} <- validate_last_run_at(last_run_at),
         true <- schema_version in [1, @schema_version] do
      %{
        id: id,
        chat_id: chat_id,
        url_sources: url_sources,
        due_time: due_time,
        last_date: last_date,
        status: status,
        last_run_at: last_run_at,
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

  defp list_records(storage) do
    storage
    |> ids()
    |> Enum.sort()
    |> Enum.flat_map(fn id ->
      case Storage.get(storage, record_key(id)) do
        {:ok, data} ->
          case decode_record(data) do
            %{} = record -> [record]
            :error -> []
          end

        :error ->
          []
      end
    end)
  end

  defp merge_scheduler_attrs(record, attrs) do
    due_time =
      case Map.has_key?(attrs, :due_time) or Map.has_key?(attrs, "due_time") do
        true -> fetch_attr(attrs, :due_time)
        false -> record.due_time
      end

    last_date =
      case Map.has_key?(attrs, :last_date) or Map.has_key?(attrs, "last_date") do
        true -> fetch_attr(attrs, :last_date)
        false -> record.last_date
      end

    status =
      case Map.has_key?(attrs, :status) or Map.has_key?(attrs, "status") do
        true -> fetch_attr(attrs, :status)
        false -> record.status
      end

    last_run_at =
      case Map.has_key?(attrs, :last_run_at) or Map.has_key?(attrs, "last_run_at") do
        true -> fetch_attr(attrs, :last_run_at)
        false -> record.last_run_at
      end

    with {:ok, due_time} <- validate_due_time(due_time),
         {:ok, last_date} <- validate_last_date(last_date),
         {:ok, status} <- validate_status(status),
         {:ok, last_run_at} <- validate_last_run_at(last_run_at) do
      {:ok,
       %{
         due_time: due_time,
         last_date: last_date,
         status: status,
         last_run_at: last_run_at
       }}
    end
  end

  defp validate_due_time(nil), do: {:ok, nil}

  defp validate_due_time({hour, minute})
       when is_integer(hour) and is_integer(minute) and hour in 0..23 and minute in 0..59 do
    {:ok, {hour, minute}}
  end

  defp validate_due_time(%{"hour" => hour, "minute" => minute}) do
    validate_due_time({hour, minute})
  end

  defp validate_due_time(%{hour: hour, minute: minute}) do
    validate_due_time({hour, minute})
  end

  defp validate_due_time(_value), do: {:error, :invalid_due_time}

  defp validate_last_date(nil), do: {:ok, nil}

  defp validate_last_date(value) when is_binary(value) do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        if Date.to_iso8601(date) == value do
          {:ok, value}
        else
          {:error, :invalid_last_date}
        end

      _ ->
        {:error, :invalid_last_date}
    end
  end

  defp validate_last_date(_value), do: {:error, :invalid_last_date}

  defp validate_status(nil), do: {:ok, nil}
  defp validate_status(:success), do: {:ok, :success}
  defp validate_status(:cutoff_reached), do: {:ok, :cutoff_reached}

  defp validate_status("success"), do: {:ok, :success}
  defp validate_status("cutoff_reached"), do: {:ok, :cutoff_reached}

  defp validate_status(_value), do: {:error, :invalid_status}

  defp validate_last_run_at(nil), do: {:ok, nil}

  defp validate_last_run_at(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, dt, 0} ->
        if DateTime.to_iso8601(dt) == value do
          {:ok, value}
        else
          {:error, :invalid_last_run_at}
        end

      _ ->
        {:error, :invalid_last_run_at}
    end
  end

  defp validate_last_run_at(%DateTime{} = value) do
    {:ok, DateTime.to_iso8601(value)}
  end

  defp validate_last_run_at(_value), do: {:error, :invalid_last_run_at}

  defp encode_due_time(nil), do: nil
  defp encode_due_time({hour, minute}), do: %{"hour" => hour, "minute" => minute}

  defp encode_status(nil), do: nil
  defp encode_status(status) when is_atom(status), do: Atom.to_string(status)
  defp encode_status(status) when is_binary(status), do: status

  defp encode_last_run_at(nil), do: nil
  defp encode_last_run_at(%DateTime{} = value), do: DateTime.to_iso8601(value)
  defp encode_last_run_at(value) when is_binary(value), do: value
end
