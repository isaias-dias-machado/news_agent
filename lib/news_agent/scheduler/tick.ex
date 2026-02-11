defmodule NewsAgent.Scheduler.Tick do
  @moduledoc """
  Periodic planner that scans users and enqueues eligible jobs or finalizes cutoffs.

  Contract: on each tick, the planner reads scheduler state for all users,
  enqueues eligible executions, and finalizes cutoffs without running jobs.

  Tensions: tick must remain lightweight, so it only emits planning actions
  and avoids any blocking job execution.
  """

  use GenServer

  alias NewsAgent.Scheduler.Config
  alias NewsAgent.Scheduler.KV
  alias NewsAgent.Scheduler.Queue

  require Logger

  @type option ::
          {:name, atom() | {:global, term()} | {:via, module(), term()}}
          | {:tick_ms, pos_integer()}
          | {:queue, module()}
          | {:queue_server, GenServer.server()}
          | {:kv, module()}
          | {:clock, (() -> DateTime.t())}

  @doc """
  Starts the scheduler tick process.
  """
  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    tick_ms = Config.tick_ms(opts)

    {:ok,
     %{
       tick_ms: tick_ms,
       queue: Keyword.get(opts, :queue, Queue),
       queue_server: Keyword.get(opts, :queue_server, Queue),
       kv: Keyword.get(opts, :kv, KV),
       clock: Keyword.get(opts, :clock, &DateTime.utc_now/0)
     }, {:continue, :tick}}
  end

  @impl true
  def handle_continue(:tick, state) do
    schedule_tick(state.tick_ms)
    {:noreply, state}
  end

  @impl true
  def handle_info(:tick, state) do
    schedule_tick(state.tick_ms)
    run_tick(state)
    {:noreply, state}
  end

  defp schedule_tick(tick_ms) do
    Process.send_after(self(), :tick, tick_ms)
  end

  defp run_tick(state) do
    :telemetry.span([:sched, :tick], %{}, fn ->
      start_time = System.monotonic_time()

      {result, metadata} =
        case state.kv.list_users() do
          {:ok, users} ->
            now = state.clock.()
            today = DateTime.to_date(now) |> Date.to_iso8601()
            {counts, metadata} = plan(users, now, today, state)
            {counts, Map.merge(metadata, %{today: today})}

          {:error, reason} ->
            Logger.debug("scheduler tick kv list failed", reason: reason)
            {zero_counts(), %{today: nil}}
        end

      duration_ms = duration_ms(start_time)

      {result,
       Map.merge(metadata, %{
         users_scanned: result.users_scanned,
         eligible_in_window: result.eligible_in_window,
         enqueued: result.enqueued,
         cutoff_finalized: result.cutoff_finalized,
         duration_ms: duration_ms
       })}
    end)
  end

  defp plan(users, now, today, state) do
    counts =
      Enum.reduce(users, zero_counts(), fn user, acc ->
        acc = %{acc | users_scanned: acc.users_scanned + 1}

        case plan_user(user, now, today, state) do
          :enqueued -> %{acc | eligible_in_window: acc.eligible_in_window + 1, enqueued: acc.enqueued + 1}
          :cutoff -> %{acc | cutoff_finalized: acc.cutoff_finalized + 1}
          :skip -> acc
        end
      end)

    metadata = %{users_scanned: counts.users_scanned}

    {counts, metadata}
  end

  defp plan_user(user, now, today, state) do
    case user do
      %{last_date: ^today} ->
        :skip

      %{due_time: due_time} ->
        {start_time, cutoff_time} = window_bounds(now, due_time)

        cond do
          DateTime.compare(now, cutoff_time) in [:eq, :gt] ->
            case state.kv.finalize_cutoff(user.user_id, today) do
              :ok -> :cutoff
              {:error, _reason} -> :skip
            end

          DateTime.compare(now, start_time) in [:eq, :gt] ->
            state.queue.enqueue(state.queue_server, user.user_id, today, now)
            :enqueued

          true ->
            :skip
        end

      _ ->
        :skip
    end
  end

  defp window_bounds(now, {hour, minute}) do
    date = DateTime.to_date(now)
    {:ok, cutoff_time} = DateTime.new(date, Time.new!(hour, minute, 0), "Etc/UTC")
    start_time = DateTime.add(cutoff_time, -Config.window_minutes() * 60, :second)
    {start_time, cutoff_time}
  end

  defp duration_ms(start_time) do
    System.monotonic_time() - start_time
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp zero_counts do
    %{users_scanned: 0, eligible_in_window: 0, enqueued: 0, cutoff_finalized: 0}
  end
end
