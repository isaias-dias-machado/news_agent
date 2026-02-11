defmodule NewsAgent.Scheduler.QueueTest do
  use ExUnit.Case, async: false

  alias NewsAgent.Scheduler.Queue

  setup do
    queue_name = :"queue_test_#{System.unique_integer([:positive])}"
    start_supervised!({Queue, [name: queue_name, retry_delay_minutes: 1]})
    %{queue_name: queue_name}
  end

  test "dedupes queued users", %{queue_name: queue_name} do
    now = DateTime.utc_now()
    today = DateTime.to_date(now) |> Date.to_iso8601()

    assert :ok = Queue.enqueue(queue_name, 1, today, now)
    assert :ok = Queue.enqueue(queue_name, 1, today, now)

    task = Task.async(fn -> Queue.take(queue_name) end)
    assert %{user_id: 1, today: ^today} = Task.await(task)
    assert 0 == Queue.depth(queue_name)
  end

  test "throttles retries until delay passes", %{queue_name: queue_name} do
    now = DateTime.utc_now()
    today = DateTime.to_date(now) |> Date.to_iso8601()

    assert :ok = Queue.enqueue(queue_name, 2, today, now)

    task = Task.async(fn -> Queue.take(queue_name) end)
    assert %{user_id: 2, today: ^today} = Task.await(task)

    Queue.complete(queue_name, 2)
    assert :ok = Queue.enqueue(queue_name, 2, today, now)
    assert 0 == Queue.depth(queue_name)
  end
end
