defmodule StorageTest do
  use ExUnit.Case, async: true

  alias NewsAgent.Storage

  test "basic functionality" do
    dir = tmp_dir()
    pid = start_store(dir)

    stats = Storage.stats(pid)
    assert stats[:keys] == 0
    assert File.exists?(log_path(dir))

    :ok = Storage.put(pid, "user:1", %{"theme" => "dark"})
    assert Storage.get(pid, "user:1") == {:ok, %{"theme" => "dark"}}

    :ok = Storage.delete(pid, "user:1")
    assert Storage.get(pid, "user:1") == :error
  end

  test "persists across restarts" do
    dir = tmp_dir()
    pid = start_store(dir)

    :ok = Storage.put(pid, "user:1", %{"theme" => "dark"})
    :ok = Storage.put(pid, "user:2", %{"theme" => "light"})

    :ok = GenServer.stop(pid)

    pid = start_store(dir)
    assert Storage.get(pid, "user:1") == {:ok, %{"theme" => "dark"}}
    assert Storage.get(pid, "user:2") == {:ok, %{"theme" => "light"}}
  end

  test "replay keeps last write" do
    dir = tmp_dir()
    pid = start_store(dir)

    :ok = Storage.put(pid, "user:1", %{"theme" => "dark"})
    :ok = Storage.put(pid, "user:1", %{"theme" => "light"})

    :ok = GenServer.stop(pid)

    pid = start_store(dir)
    assert Storage.get(pid, "user:1") == {:ok, %{"theme" => "light"}}
  end

  test "partial last line is ignored" do
    dir = tmp_dir()
    pid = start_store(dir)

    :ok = Storage.put(pid, "user:1", %{"theme" => "dark"})
    :ok = Storage.put(pid, "user:2", %{"theme" => "light"})

    :ok = GenServer.stop(pid)
    truncate_file(log_path(dir), 5)

    pid = start_store(dir)
    assert Storage.get(pid, "user:1") == {:ok, %{"theme" => "dark"}}
    assert Storage.get(pid, "user:2") == :error
  end

  test "corruption in the middle fails fast" do
    dir = tmp_dir()
    pid = start_store(dir)

    :ok = Storage.put(pid, "user:1", %{"theme" => "dark"})
    :ok = Storage.put(pid, "user:2", %{"theme" => "light"})

    :ok = GenServer.stop(pid)
    corrupt_log(log_path(dir))

    trap = Process.flag(:trap_exit, true)
    on_exit(fn -> Process.flag(:trap_exit, trap) end)

    assert {:error, reason} = Storage.start_link(dir: dir)
    assert Exception.format_exit(reason) =~ "line 2"
  end

  test "compaction creates snapshot and rotates log" do
    dir = tmp_dir()
    pid = start_store(dir, compaction_bytes: 200)

    for idx <- 1..5 do
      :ok = Storage.put(pid, "user:#{idx}", %{"payload" => String.duplicate("x", 80)})
    end

    stats = Storage.stats(pid)
    assert stats[:compactions] > 0
    assert File.exists?(snapshot_path(dir))
    assert File.exists?(rotated_log_path(dir))
    assert stats[:log_size] <= stats[:compaction_bytes]

    :ok = GenServer.stop(pid)

    pid = start_store(dir)
    assert Storage.get(pid, "user:3") == {:ok, %{"payload" => String.duplicate("x", 80)}}
  end

  test "rotation keeps exactly one debug log" do
    dir = tmp_dir()
    pid = start_store(dir)

    :ok = Storage.put(pid, "user:1", %{"theme" => "dark"})
    :ok = Storage.snapshot(pid)
    :ok = Storage.snapshot(pid)

    assert File.exists?(rotated_log_path(dir))
    refute File.exists?(Path.join(dir, "ops.log.2.jsonl"))
  end

  test "compaction blocks concurrent writes" do
    dir = tmp_dir()
    test_pid = self()
    notifier = fn event -> send(test_pid, {:compaction, event}) end

    pid =
      start_store(dir, compaction_bytes: 1, snapshot_delay_ms: 200, compaction_notifier: notifier)

    task1 = Task.async(fn -> Storage.put(pid, "user:1", %{"value" => "a"}) end)
    assert_receive {:compaction, :start}

    task2 = Task.async(fn -> Storage.put(pid, "user:2", %{"value" => "b"}) end)
    assert Task.yield(task2, 0) == nil

    assert_receive {:compaction, :finish}, 500
    assert Task.await(task1, 1000) == :ok
    assert Task.await(task2, 1000) == :ok
  end

  defp start_store(dir, opts \\ []) do
    start_supervised!({Storage, Keyword.merge([dir: dir], opts)},
      id: {Storage, System.unique_integer([:positive])}
    )
  end

  defp tmp_dir do
    base = System.tmp_dir!()
    dir = Path.join(base, "storage_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(dir)
    dir
  end

  defp truncate_file(path, bytes) do
    {:ok, fd} = :file.open(path, [:read, :write, :binary])
    {:ok, size} = :file.position(fd, :eof)
    {:ok, _} = :file.position(fd, size - bytes)
    :ok = :file.truncate(fd)
    :ok = :file.close(fd)
  end

  defp corrupt_log(path) do
    contents = File.read!(path)
    lines = String.split(contents, "\n", trim: false)

    [first | rest] = lines
    updated = Enum.join([first, "{invalid-json}"] ++ rest, "\n")
    :ok = File.write(path, updated)
  end

  defp log_path(dir), do: Path.join(dir, "ops.log.jsonl")
  defp rotated_log_path(dir), do: Path.join(dir, "ops.log.1.jsonl")
  defp snapshot_path(dir), do: Path.join(dir, "snapshot.json")
end
