defmodule NewsAgent.Scheduler.KVTest do
  use ExUnit.Case, async: false

  alias NewsAgent.Scheduler.KV
  alias NewsAgent.UserConfigs

  setup do
    dir = "data/user_configs_test_#{System.unique_integer([:positive])}"
    started? =
      case Process.whereis(UserConfigs) do
        nil ->
          start_supervised!({UserConfigs, [name: UserConfigs, dir: dir]})
          true

        _pid ->
          false
      end

    :ok = UserConfigs.clear_all()

    on_exit(fn ->
      :ok = UserConfigs.clear_all()

      if started? do
        _ = File.rm_rf(dir)
      end
    end)

    :ok
  end

  test "finalize success persists status and last_run_at" do
    {:ok, user} = UserConfigs.create(nil, [])
    assert {:ok, _updated} = UserConfigs.update_scheduler(user.id, %{due_time: {12, 0}})

    assert :ok =
             KV.put_user(%{
               user_id: user.id,
               due_time: {12, 0},
               last_date: nil,
               status: nil,
               last_run_at: nil,
               schema_version: 1
             })

    today = Date.utc_today() |> Date.to_iso8601()
    now = DateTime.utc_now()

    assert :ok = KV.finalize_success(user.id, today, now)
    assert {:ok, updated} = KV.fetch(user.id)
    assert updated.status == :success
    assert updated.last_date == today
    assert updated.last_run_at == DateTime.to_iso8601(now)
  end

  test "cutoff finalization blocks late success" do
    {:ok, user} = UserConfigs.create(nil, [])
    assert {:ok, _updated} = UserConfigs.update_scheduler(user.id, %{due_time: {8, 30}})

    assert :ok =
             KV.put_user(%{
               user_id: user.id,
               due_time: {8, 30},
               last_date: nil,
               status: nil,
               last_run_at: nil,
               schema_version: 1
             })

    today = Date.utc_today() |> Date.to_iso8601()
    assert :ok = KV.finalize_cutoff(user.id, today)
    assert :late_success = KV.finalize_success(user.id, today, DateTime.utc_now())

    assert {:ok, updated} = KV.fetch(user.id)
    assert updated.status == :cutoff_reached
    assert updated.last_date == today
  end

end
