defmodule Mix.Tasks.Storage.Smoke do
  use Mix.Task

  @shortdoc "Runs a storage smoke test"

  def run([dir]) do
    Mix.Task.run("app.start")
    {:ok, pid} = NewsAgent.Storage.start_link(dir: dir, compaction_bytes: 200)
    :ok = NewsAgent.Storage.put(pid, "user:1", %{"theme" => "dark"})
    {:ok, %{"theme" => "dark"}} = NewsAgent.Storage.get(pid, "user:1")
    :ok = NewsAgent.Storage.snapshot(pid)
    :ok = GenServer.stop(pid)
    Mix.shell().info("storage smoke test passed")
  end

  def run(_args) do
    Mix.raise("usage: mix storage.smoke DIR")
  end
end
