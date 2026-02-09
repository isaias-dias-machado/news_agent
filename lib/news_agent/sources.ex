defmodule NewsAgent.Sources do
  @moduledoc """
  Boundary for source strategy persistence and URL normalization.

  Contract: callers provide canonical source URLs and strategy data. The boundary
  normalizes URLs, validates strategy records against the required schema, and
  persists or fetches them from the configured KVStore.

  Tensions: persistence depends on external storage and can fail, and schema
  validation rejects malformed records to keep stored data consistent across
  schema versions.
  """

  alias NewsAgent.KVStore

  @schema_version 1
  @table :source_strategies

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
    case normalize_url(url) do
      {:ok, normalized_url} ->
        with_table(fn table -> KVStore.get(table, normalized_url) end)

      {:error, :invalid_url} ->
        {:error, :invalid_key}
    end
  end

  def fetch_strategy(_url), do: {:error, :invalid_key}

  @doc """
  Persists a strategy record for a canonical URL.
  """
  @spec persist_strategy(String.t(), map()) ::
          :ok | {:error, :invalid_key} | {:error, :invalid_strategy} | {:error, term()}
  def persist_strategy(canonical_url, strategy)
      when is_binary(canonical_url) and is_map(strategy) do
    with {:ok, normalized_url} <- normalize_url(canonical_url),
         {:ok, record} <- build_record(canonical_url, normalized_url, strategy),
         :ok <- with_table(fn table -> KVStore.put(table, normalized_url, record) end) do
      :ok
    else
      {:error, :invalid_url} -> {:error, :invalid_key}
      {:error, :invalid_strategy} -> {:error, :invalid_strategy}
      {:error, reason} -> {:error, reason}
    end
  end

  def persist_strategy(_canonical_url, _strategy), do: {:error, :invalid_strategy}

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
    case fetch_strategy(url) do
      {:ok, strategy} ->
        case validate_strategy(strategy) do
          :ok -> {:ok, strategy}
          {:error, :invalid_strategy} -> {:error, :invalid_strategy}
        end

      other ->
        other
    end
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

  defp with_table(fun) when is_function(fun, 1) do
    case KVStore.open(@table) do
      {:ok, table} ->
        try do
          fun.(table)
        after
          _ = KVStore.close(table)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end
end
