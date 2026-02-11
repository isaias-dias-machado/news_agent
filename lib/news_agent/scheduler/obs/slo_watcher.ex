defmodule NewsAgent.Scheduler.Obs.SLOWatcher do
  @moduledoc """
  Observability watcher that evaluates scheduler telemetry against SLO thresholds.

  Contract: collects telemetry samples over a rolling window and emits warning
  logs when thresholds are breached for the configured number of consecutive
  evaluations.

  Tensions: telemetry sampling is best-effort and runs in-memory, so warnings
  are advisory and do not guarantee complete observability coverage.
  """

  use GenServer

  alias NewsAgent.Scheduler.Config

  require Logger

  @type option ::
          {:name, atom() | {:global, term()} | {:via, module(), term()}}
          | {:slo_eval_ms, pos_integer()}
          | {:slo_window_minutes, pos_integer()}
          | {:tick_budget_ms, pos_integer()}
          | {:sat_ratio, float()}
          | {:depth_avg_max, pos_integer()}
          | {:job_p95_max_ms, pos_integer()}
          | {:cutoff_rate_max, float()}
          | {:breach_consecutive, pos_integer()}

  @doc """
  Starts the SLO watcher.
  """
  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @impl true
  def init(opts) do
    handler_id = {__MODULE__, make_ref()}
    :ok = attach(handler_id, self())

    state = %{
      handler_id: handler_id,
      slo_eval_ms: Config.slo_eval_ms(opts),
      slo_window_ms: Config.slo_window_minutes(opts) * 60_000,
      tick_budget_ms: Config.tick_budget_ms(opts),
      sat_ratio: Config.sat_ratio(opts),
      depth_avg_max: Config.depth_avg_max(opts),
      job_p95_max_ms: Config.job_p95_max_ms(opts),
      cutoff_rate_max: Config.cutoff_rate_max(opts),
      breach_consecutive: Config.breach_consecutive(opts),
      tick_samples: [],
      queue_samples: [],
      in_flight_samples: [],
      job_samples: [],
      finalize_samples: [],
      breach_counts: %{}
    }

    schedule_eval(state.slo_eval_ms)
    {:ok, state}
  end

  @impl true
  def handle_info(:evaluate, state) do
    now_ms = System.system_time(:millisecond)
    window_start = now_ms - state.slo_window_ms

    state =
      state
      |> prune_samples(window_start)
      |> evaluate(now_ms)

    schedule_eval(state.slo_eval_ms)
    {:noreply, state}
  end

  def handle_info({:telemetry, :tick, duration_ms}, state) do
    {:noreply, %{state | tick_samples: [{System.system_time(:millisecond), duration_ms} | state.tick_samples]}}
  end

  def handle_info({:telemetry, :queue, depth, today}, state) do
    sample = {System.system_time(:millisecond), depth, today}
    {:noreply, %{state | queue_samples: [sample | state.queue_samples]}}
  end

  def handle_info({:telemetry, :in_flight, in_flight, max_concurrency}, state) do
    sample = {System.system_time(:millisecond), in_flight, max_concurrency}
    {:noreply, %{state | in_flight_samples: [sample | state.in_flight_samples]}}
  end

  def handle_info({:telemetry, :job, duration_ms, result, error_class}, state) do
    sample = {System.system_time(:millisecond), duration_ms, result, error_class}
    {:noreply, %{state | job_samples: [sample | state.job_samples]}}
  end

  def handle_info({:telemetry, :finalize, status, due_bucket, today}, state) do
    sample = {System.system_time(:millisecond), status, due_bucket, today}
    {:noreply, %{state | finalize_samples: [sample | state.finalize_samples]}}
  end

  @impl true
  def terminate(_reason, state) do
    :telemetry.detach(state.handler_id)
    :ok
  end

  defp attach(handler_id, pid) do
    :telemetry.attach_many(handler_id, telemetry_events(), &__MODULE__.handle_event/4, %{pid: pid})
  end

  defp telemetry_events do
    [
      [:sched, :tick, :stop],
      [:sched, :queue, :depth],
      [:sched, :executor, :in_flight],
      [:sched, :job, :stop],
      [:sched, :finalize]
    ]
  end

  def handle_event([:sched, :tick, :stop], measurements, metadata, %{pid: pid}) do
    duration_ms = measurement_ms(measurements, metadata)
    send(pid, {:telemetry, :tick, duration_ms})
  end

  def handle_event([:sched, :queue, :depth], %{depth: depth}, metadata, %{pid: pid}) do
    send(pid, {:telemetry, :queue, depth, Map.get(metadata, :today)})
  end

  def handle_event([:sched, :executor, :in_flight], %{in_flight: in_flight}, metadata, %{pid: pid}) do
    send(pid, {:telemetry, :in_flight, in_flight, Map.get(metadata, :max_concurrency)})
  end

  def handle_event([:sched, :job, :stop], measurements, metadata, %{pid: pid}) do
    duration_ms = measurement_ms(measurements, metadata)
    result = Map.get(metadata, :result)
    error_class = Map.get(metadata, :error_class)
    send(pid, {:telemetry, :job, duration_ms, result, error_class})
  end

  def handle_event([:sched, :finalize], _measurements, metadata, %{pid: pid}) do
    send(
      pid,
      {:telemetry, :finalize, Map.get(metadata, :status), Map.get(metadata, :due_bucket), Map.get(metadata, :today)}
    )
  end

  defp measurement_ms(measurements, metadata) do
    case Map.get(measurements, :duration) do
      nil -> Map.get(metadata, :duration_ms, 0)
      duration -> System.convert_time_unit(duration, :native, :millisecond)
    end
  end

  defp prune_samples(state, window_start) do
    %{
      state
      | tick_samples: prune(state.tick_samples, window_start),
        queue_samples: prune(state.queue_samples, window_start),
        in_flight_samples: prune(state.in_flight_samples, window_start),
        job_samples: prune(state.job_samples, window_start),
        finalize_samples: prune(state.finalize_samples, window_start)
    }
  end

  defp prune(samples, window_start) do
    Enum.filter(samples, fn sample -> elem(sample, 0) >= window_start end)
  end

  defp evaluate(state, now_ms) do
    state
    |> eval_tick(now_ms)
    |> eval_saturation(now_ms)
    |> eval_queue(now_ms)
    |> eval_job_latency(now_ms)
    |> eval_cutoff(now_ms)
  end

  defp eval_tick(state, _now_ms) do
    durations = Enum.map(state.tick_samples, fn {_ts, duration} -> duration end)
    p95 = percentile(durations, 0.95)

    breach = p95 && p95 > state.tick_budget_ms

    state
    |> maybe_warn(:tick_budget, breach, fn ->
      %{window_ms: state.slo_window_ms, measured_ms: p95, threshold_ms: state.tick_budget_ms}
    end)
  end

  defp eval_saturation(state, _now_ms) do
    total = length(state.in_flight_samples)

    ratio =
      if total == 0 do
        0.0
      else
        saturated =
          Enum.count(state.in_flight_samples, fn {_ts, in_flight, max_concurrency} ->
            in_flight == max_concurrency
          end)

        saturated / total
      end

    breach = ratio > state.sat_ratio

    state
    |> maybe_warn(:saturation, breach, fn ->
      %{window_ms: state.slo_window_ms, measured_ratio: ratio, threshold_ratio: state.sat_ratio}
    end)
  end

  defp eval_queue(state, _now_ms) do
    depths = Enum.map(state.queue_samples, fn {_ts, depth, _today} -> depth end)
    avg = average(depths)

    breach_avg = avg && avg > state.depth_avg_max
    breach_slope = monotonic_increase?(depths)
    breach = breach_avg || breach_slope

    state
    |> maybe_warn(:queue_pressure, breach, fn ->
      %{
        window_ms: state.slo_window_ms,
        avg_depth: avg,
        threshold_avg: state.depth_avg_max,
        monotonic_increase: breach_slope
      }
    end)
  end

  defp eval_job_latency(state, _now_ms) do
    durations = Enum.map(state.job_samples, fn {_ts, duration, _result, _error_class} -> duration end)
    p95 = percentile(durations, 0.95)

    breach = p95 && p95 > state.job_p95_max_ms

    state
    |> maybe_warn(:job_latency, breach, fn ->
      %{window_ms: state.slo_window_ms, measured_ms: p95, threshold_ms: state.job_p95_max_ms}
    end)
  end

  defp eval_cutoff(state, _now_ms) do
    grouped =
      Enum.group_by(state.finalize_samples, fn {_ts, _status, due_bucket, _today} -> due_bucket end)

    Enum.reduce(grouped, state, fn {due_bucket, samples}, acc ->
      {successes, cutoffs} =
        Enum.reduce(samples, {0, 0}, fn {_ts, status, _bucket, _today}, {s, c} ->
          case status do
            :success -> {s + 1, c}
            :cutoff_reached -> {s, c + 1}
            _ -> {s, c}
          end
        end)

      total = successes + cutoffs

      ratio =
        if total == 0 do
          0.0
        else
          cutoffs / total
        end

      breach = ratio > acc.cutoff_rate_max

      acc
      |> maybe_warn({:cutoff_rate, due_bucket}, breach, fn ->
        %{
          window_ms: acc.slo_window_ms,
          measured_ratio: ratio,
          threshold_ratio: acc.cutoff_rate_max,
          due_bucket: due_bucket
        }
      end)
    end)
  end

  defp maybe_warn(state, key, breach, metadata_fun) do
    {count, updated} = update_breach(state, key, breach)

    if breach and count >= state.breach_consecutive do
      Logger.warning("scheduler slo breach", Map.put(metadata_fun.(), :breach_key, key))
      updated
    else
      updated
    end
  end

  defp update_breach(state, key, true) do
    count = Map.get(state.breach_counts, key, 0) + 1
    {count, %{state | breach_counts: Map.put(state.breach_counts, key, count)}}
  end

  defp update_breach(state, key, false) do
    {0, %{state | breach_counts: Map.put(state.breach_counts, key, 0)}}
  end

  defp percentile(nil, _p), do: nil
  defp percentile([], _p), do: nil

  defp percentile(values, p) when is_list(values) and p > 0 do
    sorted = Enum.sort(values)
    index = Float.ceil(p * length(sorted)) |> trunc() |> max(1)
    Enum.at(sorted, index - 1)
  end

  defp average([]), do: nil
  defp average(values), do: Enum.sum(values) / length(values)

  defp monotonic_increase?([]), do: false
  defp monotonic_increase?([_single]), do: false

  defp monotonic_increase?(values) do
    Enum.reduce_while(values, {true, nil}, fn value, {monotonic, prev} ->
      cond do
        prev == nil -> {:cont, {monotonic, value}}
        value < prev -> {:halt, {false, value}}
        true -> {:cont, {monotonic, value}}
      end
    end)
    |> case do
      {true, last} -> last != List.first(values)
      {false, _last} -> false
    end
  end

  defp schedule_eval(interval_ms) do
    Process.send_after(self(), :evaluate, interval_ms)
  end
end
