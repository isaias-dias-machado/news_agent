defmodule NewsAgent.Storage.Store do
  use GenServer

  alias NewsAgent.Storage.{Codec, FS, Stats}

  defstruct dir: nil,
            paths: %{},
            data: %{},
            log_fd: nil,
            log_size: 0,
            compaction_bytes: 1_048_576,
            fsync: true,
            stats: %Stats{},
            snapshot_delay_ms: 0,
            compaction_notifier: nil

  @type option ::
          {:dir, String.t()}
          | {:compaction_bytes, pos_integer()}
          | {:fsync, boolean()}
          | {:snapshot_delay_ms, non_neg_integer()}
          | {:compaction_notifier, pid() | (atom() -> any())}
          | {:name, atom() | {:global, term()} | {:via, module(), term()}}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def get(server, key) do
    GenServer.call(server, {:get, key})
  end

  def put(server, key, value) do
    GenServer.call(server, {:put, key, value})
  end

  def delete(server, key) do
    GenServer.call(server, {:delete, key})
  end

  def snapshot(server) do
    GenServer.call(server, :snapshot)
  end

  def stats(server) do
    GenServer.call(server, :stats)
  end

  @impl true
  def init(opts) do
    dir = Keyword.get(opts, :dir, "data/store")
    compaction_bytes = Keyword.get(opts, :compaction_bytes, 1_048_576)
    fsync = Keyword.get(opts, :fsync, true)
    snapshot_delay_ms = Keyword.get(opts, :snapshot_delay_ms, 0)
    compaction_notifier = Keyword.get(opts, :compaction_notifier)

    FS.ensure_dir!(dir)
    paths = FS.paths(dir)
    data = FS.load_snapshot!(paths.snapshot)
    {data, log_size} = FS.replay_log!(paths.log, data)
    log_fd = FS.open_log!(paths.log)

    stats = Stats.new(dir, map_size(data), log_size, compaction_bytes, fsync)

    state = %__MODULE__{
      dir: dir,
      paths: paths,
      data: data,
      log_fd: log_fd,
      log_size: log_size,
      compaction_bytes: compaction_bytes,
      fsync: fsync,
      stats: stats,
      snapshot_delay_ms: snapshot_delay_ms,
      compaction_notifier: compaction_notifier
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    if is_binary(key) do
      case Map.fetch(state.data, key) do
        {:ok, value} -> {:reply, {:ok, value}, state}
        :error -> {:reply, :error, state}
      end
    else
      {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) when is_binary(key) do
    ts = System.system_time(:millisecond)
    line = Codec.encode_op({:set, key, value, ts})
    :ok = FS.append_line!(state.log_fd, line, state.fsync)
    data = Map.put(state.data, key, value)
    log_size = state.log_size + byte_size(line)
    stats = Stats.update_after_write(state.stats, map_size(data), log_size)
    next_state = %{state | data: data, log_size: log_size, stats: stats}
    next_state = maybe_compact(next_state)
    {:reply, :ok, next_state}
  end

  def handle_call({:put, _key, _value}, _from, _state) do
    raise ArgumentError, "key must be a string"
  end

  @impl true
  def handle_call({:delete, key}, _from, state) when is_binary(key) do
    ts = System.system_time(:millisecond)
    line = Codec.encode_op({:del, key, ts})
    :ok = FS.append_line!(state.log_fd, line, state.fsync)
    data = Map.delete(state.data, key)
    log_size = state.log_size + byte_size(line)
    stats = Stats.update_after_write(state.stats, map_size(data), log_size)
    next_state = %{state | data: data, log_size: log_size, stats: stats}
    next_state = maybe_compact(next_state)
    {:reply, :ok, next_state}
  end

  def handle_call({:delete, _key}, _from, _state) do
    raise ArgumentError, "key must be a string"
  end

  @impl true
  def handle_call(:snapshot, _from, state) do
    {:reply, :ok, run_compaction(state)}
  end

  @impl true
  def handle_call(:stats, _from, state) do
    {:reply, Stats.to_map(state.stats), state}
  end

  defp maybe_compact(state) do
    if state.log_size > state.compaction_bytes do
      run_compaction(state)
    else
      state
    end
  end

  defp run_compaction(state) do
    notify(state.compaction_notifier, :start)
    maybe_delay(state.snapshot_delay_ms)
    :ok = FS.sync_log!(state.log_fd)
    snapshot_size = FS.write_snapshot_tmp!(state.paths.snapshot_tmp, state.data)
    :ok = FS.atomic_replace_snapshot!(state.paths.snapshot_tmp, state.paths.snapshot)
    {log_fd, log_size} = FS.rotate_logs!(state.paths.log, state.paths.rotated, state.log_fd)
    notify(state.compaction_notifier, :finish)
    stats = Stats.note_compaction(state.stats, map_size(state.data), log_size, snapshot_size)

    %{
      state
      | log_fd: log_fd,
        log_size: log_size,
        stats: stats
    }
  end

  defp notify(nil, _event), do: :ok
  defp notify(pid, event) when is_pid(pid), do: send(pid, {:compaction, event})
  defp notify(fun, event) when is_function(fun, 1), do: fun.(event)

  defp maybe_delay(0), do: :ok
  defp maybe_delay(ms), do: Process.sleep(ms)
end
