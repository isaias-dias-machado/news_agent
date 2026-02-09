defmodule NewsAgent.KVStore do
  @moduledoc """
  Boundary for durable key-value storage backed by `:dets`.

  Contract: callers open a named table and receive a handle to use for CRUD
  operations. Keys are normalized to strings (atoms are converted), and values
  are stored as-is. All operations are synchronous and persist data to disk.

  Tensions: operations depend on filesystem availability and `:dets` table
  lifecycle. Callers must handle errors from I/O, closed tables, and ensure
  key normalization rules are respected.
  """

  @type table :: term()
  @type key_input :: String.t() | atom()

  @doc """
  Opens a `:dets` table stored at `data/kv/<table>.dets`.

  The table name is normalized to a string for the file path and a stable table
  identifier is returned on success.
  """
  @spec open(String.t() | atom()) :: {:ok, table()} | {:error, term()}
  def open(table) do
    with {:ok, table_name} <- normalize_table(table),
         :ok <- File.mkdir_p(kv_dir()),
         {:ok, dets_table} <-
           :dets.open_file(table_id(table_name),
             type: :set,
             file: table_path(table_name)
           ) do
      {:ok, dets_table}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Closes a previously opened `:dets` table.
  """
  @spec close(table()) :: :ok | {:error, term()}
  def close(table) do
    :dets.close(table)
  end

  @doc """
  Fetches a value for the given key.

  Returns `{:error, :not_found}` when the key is absent.
  """
  @spec get(table(), key_input()) :: {:ok, term()} | {:error, :not_found | :invalid_key | term()}
  def get(table, key) do
    with {:ok, normalized} <- normalize_key(key) do
      case :dets.lookup(table, normalized) do
        [{^normalized, value}] -> {:ok, value}
        [] -> {:error, :not_found}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  @doc """
  Stores a value for the given key, overwriting any existing entry.
  """
  @spec put(table(), key_input(), term()) :: :ok | {:error, :invalid_key | term()}
  def put(table, key, value) do
    with {:ok, normalized} <- normalize_key(key),
         :ok <- :dets.insert(table, {normalized, value}) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deletes the entry for the given key.
  """
  @spec delete(table(), key_input()) :: :ok | {:error, :invalid_key | term()}
  def delete(table, key) do
    with {:ok, normalized} <- normalize_key(key),
         :ok <- :dets.delete(table, normalized) do
      :ok
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns all key-value pairs stored in the table.

  Keys are returned as normalized strings.
  """
  @spec all(table()) :: {:ok, [{String.t(), term()}]} | {:error, term()}
  def all(table) do
    case :dets.foldl(fn entry, acc -> [entry | acc] end, [], table) do
      {:error, reason} -> {:error, reason}
      entries -> {:ok, Enum.reverse(entries)}
    end
  end

  @doc """
  Updates a value by applying `fun` to the current value.

  When the key is missing, the provided default is used as input to `fun`.
  """
  @spec update(table(), key_input(), (term() -> term()), term()) ::
          {:ok, term()} | {:error, :invalid_key | term()}
  def update(table, key, fun, default) when is_function(fun, 1) do
    with {:ok, normalized} <- normalize_key(key),
         {:ok, current} <- current_value(table, normalized, default),
         updated <- fun.(current),
         :ok <- :dets.insert(table, {normalized, updated}) do
      {:ok, updated}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp current_value(table, key, default) do
    case :dets.lookup(table, key) do
      [{^key, value}] -> {:ok, value}
      [] -> {:ok, default}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_key(key) when is_binary(key), do: {:ok, key}
  defp normalize_key(key) when is_atom(key), do: {:ok, Atom.to_string(key)}
  defp normalize_key(_key), do: {:error, :invalid_key}

  defp normalize_table(table) when is_binary(table), do: {:ok, table}
  defp normalize_table(table) when is_atom(table), do: {:ok, Atom.to_string(table)}
  defp normalize_table(_table), do: {:error, :invalid_table}

  defp kv_dir do
    Path.join(["data", "kv"])
  end

  defp table_path(table_name) do
    kv_dir()
    |> Path.join("#{table_name}.dets")
    |> String.to_charlist()
  end

  defp table_id(table_name) do
    {__MODULE__, table_name}
  end
end
