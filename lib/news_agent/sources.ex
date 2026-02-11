defmodule NewsAgent.Sources do
  @moduledoc """
  Boundary for source strategy persistence and URL normalization.

  Contract: callers provide canonical source URLs and strategy data. The boundary
  normalizes URLs, validates strategy records against the required schema, and
  persists or fetches them from the configured append-only storage.

  Tensions: persistence depends on external storage and can fail, and schema
  validation rejects malformed records to keep stored data consistent across
  schema versions.
  """

  use GenServer

  alias NewsAgent.Storage

  @schema_version 1

  @required_keys [
    :canonical_url,
    :normalized_url,
    :strategy,
    :confidence,
    :schema_version,
    :last_verified_at
  ]

  @type strategy_details :: %{
          required(:type) => String.t() | atom(),
          required(:source_url) => String.t(),
          optional(atom()) => term()
        }

  @type strategy_record :: %{
          required(:canonical_url) => String.t(),
          required(:normalized_url) => String.t(),
          required(:strategy) => strategy_details(),
          required(:confidence) => number(),
          required(:schema_version) => integer(),
          required(:last_verified_at) => term()
        }

  @type option ::
          {:dir, String.t()}
          | {:storage_name, atom()}
          | {:name, atom() | {:global, term()} | {:via, module(), term()}}

  @doc """
  Starts the Sources storage process.
  """
  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Normalizes a URL for use as a persistence key.

  Hostnames are lowercased and fragments are stripped while preserving path and
  query components.
  """
  @spec normalize_url(String.t()) :: {:ok, String.t()} | {:error, :invalid_url}
  def normalize_url(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} = uri when is_binary(scheme) and is_binary(host) ->
        normalized_uri = %URI{uri | host: String.downcase(host), fragment: nil}
        {:ok, URI.to_string(normalized_uri)}

      _ ->
        {:error, :invalid_url}
    end
  end

  def normalize_url(_url), do: {:error, :invalid_url}

  @doc """
  Fetches a persisted strategy record for a canonical URL.
  """
  @spec fetch_strategy(String.t()) ::
          {:ok, strategy_record()} | :error | {:error, :invalid_key} | {:error, term()}
  def fetch_strategy(url) when is_binary(url) do
    fetch_strategy(__MODULE__, url)
  end

  def fetch_strategy(_url), do: {:error, :invalid_key}

  @doc """
  Fetches a persisted strategy record from a specific server.
  """
  @spec fetch_strategy(GenServer.server(), String.t()) ::
          {:ok, strategy_record()} | :error | {:error, :invalid_key} | {:error, term()}
  def fetch_strategy(server, url) when is_binary(url) do
    case normalize_url(url) do
      {:ok, normalized_url} ->
        GenServer.call(server, {:fetch, normalized_url})

      {:error, :invalid_url} ->
        {:error, :invalid_key}
    end
  end

  def fetch_strategy(_server, _url), do: {:error, :invalid_key}

  @doc """
  Persists a strategy record for a canonical URL.
  """
  @spec persist_strategy(String.t(), map()) ::
          :ok | {:error, :invalid_key} | {:error, :invalid_strategy} | {:error, term()}
  def persist_strategy(canonical_url, strategy)
      when is_binary(canonical_url) and is_map(strategy) do
    persist_strategy(__MODULE__, canonical_url, strategy)
  end

  def persist_strategy(_canonical_url, _strategy), do: {:error, :invalid_strategy}

  @doc """
  Persists a strategy record for a canonical URL on a specific server.
  """
  @spec persist_strategy(GenServer.server(), String.t(), map()) ::
          :ok | {:error, :invalid_key} | {:error, :invalid_strategy} | {:error, term()}
  def persist_strategy(server, canonical_url, strategy)
      when is_binary(canonical_url) and is_map(strategy) do
    with {:ok, normalized_url} <- normalize_url(canonical_url),
         {:ok, record} <- build_record(canonical_url, normalized_url, strategy),
         :ok <- GenServer.call(server, {:persist, normalized_url, record}) do
      :ok
    else
      {:error, :invalid_url} -> {:error, :invalid_key}
      {:error, :invalid_strategy} -> {:error, :invalid_strategy}
      {:error, reason} -> {:error, reason}
    end
  end

  def persist_strategy(_server, _canonical_url, _strategy), do: {:error, :invalid_strategy}

  @doc """
  Fetches and validates a persisted strategy record for a canonical URL.
  """
  @spec strategy_for(String.t()) ::
          {:ok, strategy_record()}
          | :error
          | {:error, :invalid_key}
          | {:error, :invalid_strategy}
          | {:error, term()}
  def strategy_for(url) do
    strategy_for(__MODULE__, url)
  end

  @doc """
  Fetches and validates a persisted strategy record from a specific server.
  """
  @spec strategy_for(GenServer.server(), String.t()) ::
          {:ok, strategy_record()}
          | :error
          | {:error, :invalid_key}
          | {:error, :invalid_strategy}
          | {:error, term()}
  def strategy_for(server, url) do
    case fetch_strategy(server, url) do
      {:ok, strategy} ->
        case validate_strategy(strategy) do
          :ok -> {:ok, strategy}
          {:error, :invalid_strategy} -> {:error, :invalid_strategy}
        end

      other ->
        other
    end
  end

  @impl true
  def init(opts) do
    dir = Keyword.get(opts, :dir, "data/source_strategies")
    storage_name = Keyword.get(opts, :storage_name, storage_name())
    {:ok, storage} = Storage.start_link(dir: dir, name: storage_name)
    {:ok, %{storage: storage}}
  end

  @impl true
  def handle_call({:fetch, key}, _from, state) do
    reply = Storage.get(state.storage, key)
    {:reply, reply, state}
  end

  def handle_call({:persist, key, record}, _from, state) do
    :ok = Storage.put(state.storage, key, record)
    {:reply, :ok, state}
  end

  defp build_record(canonical_url, normalized_url, strategy) do
    record =
      strategy
      |> Map.put(:canonical_url, canonical_url)
      |> Map.put(:normalized_url, normalized_url)
      |> Map.put(:schema_version, @schema_version)

    case validate_strategy(record) do
      :ok -> {:ok, record}
      {:error, :invalid_strategy} -> {:error, :invalid_strategy}
    end
  end

  defp validate_strategy(%{} = record) do
    if Enum.all?(@required_keys, &Map.has_key?(record, &1)) and valid_strategy?(record) do
      :ok
    else
      {:error, :invalid_strategy}
    end
  end

  defp validate_strategy(_record), do: {:error, :invalid_strategy}

  defp valid_strategy?(%{strategy: %{} = strategy}) do
    case {Map.get(strategy, :type), Map.get(strategy, :source_url)} do
      {type, source_url}
      when (is_atom(type) or is_binary(type)) and is_binary(source_url) and source_url != "" ->
        true

      _ ->
        false
    end
  end

  defp valid_strategy?(_record), do: false

  defp storage_name do
    Module.concat(__MODULE__, Storage)
  end
end
