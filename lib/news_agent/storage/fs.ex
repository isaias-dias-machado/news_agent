defmodule NewsAgent.Storage.FS do
  @moduledoc false

  alias NewsAgent.Storage.Codec

  def paths(dir) do
    %{
      dir: dir,
      snapshot: Path.join(dir, "snapshot.json"),
      snapshot_tmp: Path.join(dir, "snapshot.json.tmp"),
      log: Path.join(dir, "ops.log.jsonl"),
      rotated: Path.join(dir, "ops.log.1.jsonl")
    }
  end

  def ensure_dir!(dir) do
    case File.mkdir_p(dir) do
      :ok -> :ok
      {:error, reason} -> raise "unable to create dir #{dir}: #{inspect(reason)}"
    end

    _ = File.chmod(dir, 0o700)
    :ok
  end

  def load_snapshot!(path) do
    if File.exists?(path) do
      snapshot = Jason.decode!(File.read!(path))

      if is_map(snapshot) do
        snapshot
      else
        raise "snapshot must be a JSON object"
      end
    else
      %{}
    end
  end

  def replay_log!(path, data) do
    if File.exists?(path) do
      {:ok, fd} = :file.open(path, [:read, :write, :binary])
      {data, log_size} = replay_from_fd(fd, data, 0, 0)
      :ok = :file.close(fd)
      {data, log_size}
    else
      {data, 0}
    end
  end

  def open_log!(path) do
    case :file.open(path, [:append, :binary]) do
      {:ok, fd} -> fd
      {:error, reason} -> raise "unable to open log #{path}: #{inspect(reason)}"
    end
  end

  def append_line!(fd, line, fsync?) do
    case :file.write(fd, line) do
      :ok -> :ok
      {:error, reason} -> raise "unable to append log: #{inspect(reason)}"
    end

    if fsync? do
      sync_log!(fd)
    end

    :ok
  end

  def sync_log!(fd) do
    case :file.sync(fd) do
      :ok -> :ok
      {:error, reason} -> raise "unable to sync log: #{inspect(reason)}"
    end
  end

  def write_snapshot_tmp!(path, data) do
    json = Jason.encode!(data)

    case :file.open(path, [:write, :binary]) do
      {:ok, fd} ->
        :ok = :file.write(fd, json)
        :ok = :file.sync(fd)
        :ok = :file.close(fd)
        byte_size(json)

      {:error, reason} ->
        raise "unable to write snapshot #{path}: #{inspect(reason)}"
    end
  end

  def atomic_replace_snapshot!(tmp_path, snapshot_path) do
    case File.rename(tmp_path, snapshot_path) do
      :ok -> :ok
      {:error, reason} -> raise "unable to replace snapshot: #{inspect(reason)}"
    end
  end

  def rotate_logs!(log_path, rotated_path, fd) do
    :ok = :file.close(fd)

    if File.exists?(rotated_path) do
      File.rm!(rotated_path)
    end

    if File.exists?(log_path) do
      case File.rename(log_path, rotated_path) do
        :ok -> :ok
        {:error, reason} -> raise "unable to rotate log: #{inspect(reason)}"
      end
    end

    {open_log!(log_path), 0}
  end

  defp replay_from_fd(fd, data, line_number, offset) do
    case :file.read_line(fd) do
      :eof ->
        {data, offset}

      {:ok, line} ->
        line_number = line_number + 1
        line_size = byte_size(line)

        if String.ends_with?(line, "\n") do
          op = Codec.decode_line!(line, line_number)
          replay_from_fd(fd, apply_op(data, op), line_number, offset + line_size)
        else
          {:ok, _} = :file.position(fd, offset)
          :ok = :file.truncate(fd)
          {data, offset}
        end

      {:error, reason} ->
        raise "log read error at line #{line_number + 1}: #{inspect(reason)}"
    end
  end

  defp apply_op(data, {:set, key, value, _ts}) do
    Map.put(data, key, value)
  end

  defp apply_op(data, {:del, key, _ts}) do
    Map.delete(data, key)
  end
end
