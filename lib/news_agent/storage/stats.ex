defmodule NewsAgent.Storage.Stats do
  @moduledoc false

  defstruct dir: nil,
            keys: 0,
            log_size: 0,
            compaction_bytes: 1_048_576,
            fsync: true,
            compactions: 0,
            last_snapshot_at: nil,
            last_snapshot_size: nil

  @type t :: %__MODULE__{
          dir: String.t() | nil,
          keys: non_neg_integer(),
          log_size: non_neg_integer(),
          compaction_bytes: pos_integer(),
          fsync: boolean(),
          compactions: non_neg_integer(),
          last_snapshot_at: integer() | nil,
          last_snapshot_size: non_neg_integer() | nil
        }

  def new(dir, keys, log_size, compaction_bytes, fsync) do
    %__MODULE__{
      dir: dir,
      keys: keys,
      log_size: log_size,
      compaction_bytes: compaction_bytes,
      fsync: fsync
    }
  end

  def update_after_write(stats, keys, log_size) do
    %{stats | keys: keys, log_size: log_size}
  end

  def note_compaction(stats, keys, log_size, snapshot_size) do
    %{
      stats
      | keys: keys,
        log_size: log_size,
        compactions: stats.compactions + 1,
        last_snapshot_at: System.system_time(:millisecond),
        last_snapshot_size: snapshot_size
    }
  end

  def to_map(stats) do
    Map.from_struct(stats)
  end
end
