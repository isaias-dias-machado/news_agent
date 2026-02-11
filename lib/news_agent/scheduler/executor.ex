defmodule NewsAgent.Scheduler.Executor do
  @moduledoc """
  Executes scheduled jobs with bounded concurrency.

  Contract: continuously drains the scheduler queue, runs jobs through the
  configured runner, and finalizes success outcomes while respecting cutoff
  boundaries.

  Tensions: execution is asynchronous and may fail or time out, so completion
  must always release queue dedupe state without finalizing failures.
  """

  use GenServer

  alias NewsAgent.Scheduler.Config
  alias NewsAgent.Scheduler.KV
  alias NewsAgent.Scheduler.Queue

  require Logger

  @type option ::
          {:name, atom() | {:global, term()} | {:via, module(), term()}}
          | {:queue, module()}
          | {:queue_server, GenServer.server()}
          | {:kv, module()}
          | {:task_supervisor, atom()}
          | {:job_runner, module()}
          | {:max_concurrency, pos_integer()}
          | {:job_timeout_ms, pos_integer()}
          | {:clock, (() -> DateTime.t())}

  @doc """
  Starts the scheduler executor.
  """
  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    state = %{
      queue: Keyword.get(opts, :queue, Queue),
      queue_server: Keyword.get(opts, :queue_server, Queue),
      kv: Keyword.get(opts, :kv, KV),
      task_supervisor: Keyword.get(opts, :task_supervisor, NewsAgent.Scheduler.TaskSupervisor),
      job_runner: Config.job_runner(opts),
      max_concurrency: Config.max_concurrency(opts),
      job_timeout_ms: Config.job_timeout_ms(opts),
      clock: Keyword.get(opts, :clock, &DateTime.utc_now/0),
      in_flight: 0,
      stream_task: nil
    }

    {:ok, stream_task} = Task.start_link(fn -> run_stream(state, self()) end)

    {:ok, %{state | stream_task: stream_task}}
  end

  @impl true
  def handle_info({:job_started, _user_id}, state) do
    updated = %{state | in_flight: state.in_flight + 1}
    emit_in_flight(updated)
    {:noreply, updated}
  end

  def handle_info({:job_finished, _user_id}, state) do
    updated = %{state | in_flight: max(state.in_flight - 1, 0)}
    emit_in_flight(updated)
    {:noreply, updated}
  end

  def handle_info({:EXIT, pid, reason}, state) do
    if pid == state.stream_task do
      Logger.warning("scheduler executor stream exited", reason: reason)
    end

    {:noreply, state}
  end

  defp run_stream(state, executor_pid) do
    stream = Stream.repeatedly(fn -> state.queue.take(state.queue_server) end)

    options = [
      max_concurrency: state.max_concurrency,
      ordered: false,
      timeout: state.job_timeout_ms,
      on_timeout: :kill_task,
      zip_input_on_exit: true
    ]

    Task.Supervisor.async_stream_nolink(state.task_supervisor, stream, fn job ->
      send(executor_pid, {:job_started, job.user_id})
      run_job(job, state)
    end, options)
    |> Stream.each(fn
      {:ok, {job, result}} ->
        handle_job_result(job, result, state, executor_pid)

      {:exit, {job, reason}} ->
        handle_job_exit(job, reason, state, executor_pid)

      {:exit, reason} ->
        Logger.debug("scheduler job exited", reason: reason)
    end)
    |> Stream.run()
  end

  defp run_job(job, state) do
    start_time = System.monotonic_time()

    result =
      try do
        state.job_runner.run(job.user_id, job.today)
      rescue
        error ->
          {:error, {:exception, error}}
      catch
        kind, reason ->
          {:error, {kind, reason}}
      end

    duration_ms = duration_ms(start_time)

    :telemetry.span([:sched, :job], %{}, fn ->
      metadata =
        case result do
          :ok -> %{result: :ok}
          {:error, reason} -> %{result: :error, error_class: error_class(reason)}
          _ -> %{result: :error, error_class: :unknown}
        end

      {result, Map.put(metadata, :duration_ms, duration_ms)}
    end)

    {job, result}
  end

  defp handle_job_result(job, result, state, executor_pid) do
    state.queue.complete(state.queue_server, job.user_id)

    case result do
      :ok ->
        case state.kv.finalize_success(job.user_id, job.today, state.clock.()) do
          :ok -> :ok
          :late_success -> Logger.debug("scheduler late success", user_id: job.user_id)
          {:error, reason} -> Logger.debug("scheduler kv success finalize failed", reason: reason)
        end

      {:error, reason} ->
        Logger.debug("scheduler job failed", reason: reason)

      other ->
        Logger.debug("scheduler job unexpected result", result: other)
    end

    send(executor_pid, {:job_finished, job.user_id})
  end

  defp handle_job_exit(job, :timeout, state, executor_pid) do
    state.queue.complete(state.queue_server, job.user_id)

    :telemetry.execute(
      [:sched, :job, :stop],
      %{duration_ms: state.job_timeout_ms},
      %{result: :timeout, error_class: :unknown}
    )

    Logger.debug("scheduler job timeout", user_id: job.user_id)
    send(executor_pid, {:job_finished, job.user_id})
  end

  defp handle_job_exit(job, reason, state, executor_pid) do
    state.queue.complete(state.queue_server, job.user_id)

    :telemetry.execute(
      [:sched, :job, :stop],
      %{duration_ms: state.job_timeout_ms},
      %{result: :error, error_class: error_class(reason)}
    )

    Logger.debug("scheduler job exit", user_id: job.user_id, reason: reason)
    send(executor_pid, {:job_finished, job.user_id})
  end

  defp emit_in_flight(state) do
    :telemetry.execute(
      [:sched, :executor, :in_flight],
      %{in_flight: state.in_flight},
      %{max_concurrency: state.max_concurrency}
    )
  end

  defp duration_ms(start_time) do
    System.monotonic_time() - start_time
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp error_class({:req, _reason}), do: :req
  defp error_class({:llm, _reason}), do: :llm
  defp error_class({:parse, _reason}), do: :parse
  defp error_class({:exception, _error}), do: :unknown
  defp error_class({_kind, _reason}), do: :unknown
  defp error_class(_reason), do: :unknown
end
