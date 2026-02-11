defmodule NewsAgent.Scheduler.Queue do
  @moduledoc """
  Manages the in-memory scheduler queue with dedupe and retry throttling.

  Contract: callers enqueue eligible users, while consumers take queued jobs and
  notify completion. The queue prevents duplicate in-flight runs and enforces
  retry delays.

  Tensions: in-memory state is ephemeral and must be recomputed after restarts,
  so callers must persist final outcomes elsewhere.
  """

  use GenServer

  alias NewsAgent.Scheduler.Config

  require Logger

  @type job :: %{user_id: term(), today: String.t()}

  @type option ::
          {:name, atom() | {:global, term()} | {:via, module(), term()}}
          | {:retry_delay_minutes, pos_integer()}

  @doc """
  Starts the scheduler queue.
  """
  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Enqueues a user for execution if not already queued or throttled.
  """
  @spec enqueue(term(), String.t(), DateTime.t()) :: :ok
  def enqueue(user_id, today, now) do
    enqueue(__MODULE__, user_id, today, now)
  end

  @doc """
  Enqueues a user for execution against a specific queue process.
  """
  @spec enqueue(GenServer.server(), term(), String.t(), DateTime.t()) :: :ok
  def enqueue(server, user_id, today, now) do
    GenServer.cast(server, {:enqueue, user_id, today, now})
  end

  @doc """
  Takes the next available job, blocking until one is available.
  """
  @spec take() :: job()
  def take do
    take(__MODULE__)
  end

  @doc """
  Takes the next available job from a specific queue process.
  """
  @spec take(GenServer.server()) :: job()
  def take(server) do
    GenServer.call(server, :take, :infinity)
  end

  @doc """
  Marks a job complete, releasing the user for future retries.
  """
  @spec complete(term()) :: :ok
  def complete(user_id) do
    complete(__MODULE__, user_id)
  end

  @doc """
  Marks a job complete on a specific queue process.
  """
  @spec complete(GenServer.server(), term()) :: :ok
  def complete(server, user_id) do
    GenServer.cast(server, {:complete, user_id})
  end

  @doc """
  Returns the current queue depth.
  """
  @spec depth() :: non_neg_integer()
  def depth do
    depth(__MODULE__)
  end

  @doc """
  Returns the queue depth for a specific queue process.
  """
  @spec depth(GenServer.server()) :: non_neg_integer()
  def depth(server) do
    GenServer.call(server, :depth)
  end

  @impl true
  def init(opts) do
    retry_delay_minutes = Config.retry_delay_minutes(opts)
    retry_delay_ms = retry_delay_minutes * 60_000

    {:ok,
     %{
       queue: :queue.new(),
       queued_or_running: MapSet.new(),
       next_attempt_at: %{},
       waiters: :queue.new(),
       retry_delay_ms: retry_delay_ms
     }}
  end

  @impl true
  def handle_cast({:enqueue, user_id, today, now}, state) do
    now_ms = DateTime.to_unix(now, :millisecond)
    throttle_key = {user_id, today}

    cond do
      MapSet.member?(state.queued_or_running, user_id) ->
        Logger.debug("scheduler enqueue ignored", reason: :already_queued, user_id: user_id)
        {:noreply, state}

      throttled?(state.next_attempt_at, throttle_key, now_ms) ->
        Logger.debug("scheduler enqueue ignored", reason: :throttled, user_id: user_id)
        {:noreply, state}

      true ->
        updated_state =
          state
          |> enqueue_job(%{user_id: user_id, today: today})
          |> put_next_attempt(throttle_key, now_ms)

        {:noreply, updated_state}
    end
  end

  def handle_cast({:complete, user_id}, state) do
    updated = %{state | queued_or_running: MapSet.delete(state.queued_or_running, user_id)}
    emit_depth(updated)
    {:noreply, updated}
  end

  @impl true
  def handle_call(:take, from, state) do
    case :queue.out(state.queue) do
      {{:value, job}, queue} ->
        updated = %{state | queue: queue}
        emit_depth(updated)
        {:reply, job, updated}

      {:empty, _queue} ->
        updated = %{state | waiters: :queue.in(from, state.waiters)}
        {:noreply, updated}
    end
  end

  def handle_call(:depth, _from, state) do
    {:reply, :queue.len(state.queue), state}
  end

  defp enqueue_job(state, job) do
    state
    |> maybe_wake_waiter(job)
    |> ensure_queued(job)
  end

  defp maybe_wake_waiter(state, job) do
    case :queue.out(state.waiters) do
      {{:value, waiter}, waiters} ->
        GenServer.reply(waiter, job)
        %{state | waiters: waiters, queued_or_running: MapSet.put(state.queued_or_running, job.user_id)}

      {:empty, _waiters} ->
        state
    end
  end

  defp ensure_queued(%{queue: queue} = state, job) do
    if job_in_queue?(state, job.user_id) do
      state
    else
      updated_queue = :queue.in(job, queue)
      updated = %{state | queue: updated_queue, queued_or_running: MapSet.put(state.queued_or_running, job.user_id)}
      emit_depth(updated)
      updated
    end
  end

  defp job_in_queue?(state, user_id) do
    MapSet.member?(state.queued_or_running, user_id)
  end

  defp put_next_attempt(state, key, now_ms) do
    next_attempt_at = Map.put(state.next_attempt_at, key, now_ms + state.retry_delay_ms)
    %{state | next_attempt_at: next_attempt_at}
  end

  defp throttled?(next_attempt_at, key, now_ms) do
    case Map.get(next_attempt_at, key) do
      nil -> false
      time_ms when is_integer(time_ms) -> now_ms < time_ms
    end
  end

  defp emit_depth(state) do
    :telemetry.execute(
      [:sched, :queue, :depth],
      %{depth: :queue.len(state.queue)},
      %{today: current_today()}
    )
  end

  defp current_today do
    DateTime.utc_now()
    |> DateTime.to_date()
    |> Date.to_iso8601()
  end
end
