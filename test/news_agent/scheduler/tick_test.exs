defmodule NewsAgent.Scheduler.TickTest do
  use ExUnit.Case, async: false

  alias NewsAgent.Scheduler.KV
  alias NewsAgent.Scheduler.Queue
  alias NewsAgent.Scheduler.Tick
  alias NewsAgent.UserConfigs

  setup do
    dir = "data/user_configs_test_#{System.unique_integer([:positive])}"
    queue_name = :"queue_test_#{System.unique_integer([:positive])}"

    started? =
      case Process.whereis(UserConfigs) do
        nil ->
          start_supervised!({UserConfigs, [name: UserConfigs, dir: dir]})
          true

        _pid ->
          false
      end

    :ok = UserConfigs.clear_all()
    start_supervised!({Queue, [name: queue_name]})

    on_exit(fn ->
      :ok = UserConfigs.clear_all()

      if started? do
        _ = File.rm_rf(dir)
      end
    end)

    %{queue_name: queue_name}
  end

  test "enqueues users inside the delivery window", %{queue_name: queue_name} do
    now = ~U[2026-02-11 12:00:00Z]
    today = DateTime.to_date(now) |> Date.to_iso8601()

    {:ok, user} = UserConfigs.create(nil, [])
    user_id = user.id
    assert {:ok, _updated} = UserConfigs.update_scheduler(user_id, %{due_time: {12, 30}})

    tick_name = :"tick_test_#{System.unique_integer([:positive])}"

    tick =
      start_supervised!({Tick,
        name: tick_name,
        tick_ms: 60_000,
        clock: fn -> now end,
        queue: Queue,
        queue_server: queue_name,
        kv: KV
      })

    send(tick, :tick)
    _ = :sys.get_state(tick)

    task = Task.async(fn -> Queue.take(queue_name) end)
    assert %{user_id: ^user_id, today: ^today} = Task.await(task)
  end

  test "finalizes cutoff once past due time", %{queue_name: queue_name} do
    now = ~U[2026-02-11 12:00:00Z]
    today = DateTime.to_date(now) |> Date.to_iso8601()

    {:ok, user} = UserConfigs.create(nil, [])
    user_id = user.id
    assert {:ok, _updated} = UserConfigs.update_scheduler(user_id, %{due_time: {11, 0}})

    tick_name = :"tick_test_#{System.unique_integer([:positive])}"

    tick =
      start_supervised!({Tick,
        name: tick_name,
        tick_ms: 60_000,
        clock: fn -> now end,
        queue: Queue,
        queue_server: queue_name,
        kv: KV
      })

    send(tick, :tick)
    _ = :sys.get_state(tick)

    assert {:ok, updated} = KV.fetch(user_id)
    assert updated.status == :cutoff_reached
    assert updated.last_date == today
  end
end
