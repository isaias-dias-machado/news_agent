defmodule NewsAgent.Scheduler.Obs.SLOWatcherTest do
  use ExUnit.Case, async: false

  alias NewsAgent.Scheduler.Obs.SLOWatcher

  test "evaluates empty samples without crashing" do
    name = String.to_atom("slo_watcher_test_#{System.unique_integer([:positive])}")

    pid =
      start_supervised!({SLOWatcher, name: name, slo_eval_ms: 60_000})

    ref = Process.monitor(pid)

    send(pid, :evaluate)
    _ = :sys.get_state(pid)

    refute_receive {:DOWN, ^ref, :process, ^pid, _reason}
  end
end
