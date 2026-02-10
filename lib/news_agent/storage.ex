defmodule NewsAgent.Storage do
  @moduledoc """
  Boundary for the append-only JSONL store.

  Contract: each write appends a strictly validated JSON line and is optionally
  synchronized to disk via fsync. Reads are served from in-memory state rebuilt
  from the snapshot and log on startup. Compaction is synchronous and blocks
  callers while a snapshot is persisted and the log is rotated.

  Tensions: storage depends on filesystem durability and strict replay rules.
  Corruption in the middle of the log causes startup to fail fast with line
  detail, while a partial last line is ignored. Callers should expect crashes
  when strictness or persistence guarantees cannot be met.
  """

  @type option ::
          {:dir, String.t()}
          | {:compaction_bytes, pos_integer()}
          | {:fsync, boolean()}
          | {:name, atom() | {:global, term()} | {:via, module(), term()}}

  @doc """
  Starts a storage store process.
  """
  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    NewsAgent.Storage.Store.start_link(opts)
  end

  @doc """
  Returns the value for the given key.
  """
  @spec get(pid(), String.t()) :: {:ok, term()} | :error
  def get(server, key) do
    NewsAgent.Storage.Store.get(server, key)
  end

  @doc """
  Stores the value for the given key.
  """
  @spec put(pid(), String.t(), term()) :: :ok
  def put(server, key, value) do
    NewsAgent.Storage.Store.put(server, key, value)
  end

  @doc """
  Deletes the value for the given key.
  """
  @spec delete(pid(), String.t()) :: :ok
  def delete(server, key) do
    NewsAgent.Storage.Store.delete(server, key)
  end

  @doc """
  Forces a synchronous snapshot and log rotation.
  """
  @spec snapshot(pid()) :: :ok
  def snapshot(server) do
    NewsAgent.Storage.Store.snapshot(server)
  end

  @doc """
  Returns store statistics.
  """
  @spec stats(pid()) :: map()
  def stats(server) do
    NewsAgent.Storage.Store.stats(server)
  end

  @doc """
  Returns a child specification for supervising a store.
  """
  @spec child_spec([option()]) :: Supervisor.child_spec()
  def child_spec(opts) do
    NewsAgent.Storage.Store.child_spec(opts)
  end
end
