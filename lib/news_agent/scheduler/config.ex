defmodule NewsAgent.Scheduler.Config do
  @moduledoc """
  Provides configuration access for scheduler runtime components.

  Contract: callers fetch scheduler and SLO defaults with optional overrides,
  relying on the application environment as the source of truth.

  Tensions: configuration values may be missing or malformed, so defaults are
  applied consistently across scheduler modules.
  """

  @scheduler_key :scheduler
  @slo_key :scheduler_slo

  @default_tick_ms 60_000
  @default_max_concurrency 4
  @default_job_timeout_ms 120_000
  @default_window_minutes 60
  @default_retry_delay_minutes 10
  @default_job_runner NewsAgent.Scheduler.JobRunner

  @default_slo_eval_ms 60_000
  @default_slo_window_minutes 15
  @default_tick_budget_ms 300
  @default_sat_ratio 0.8
  @default_depth_avg_max 50
  @default_job_p95_max_ms 30_000
  @default_cutoff_rate_max 0.2
  @default_breach_consecutive 3

  @doc """
  Returns scheduler runtime configuration with defaults applied.
  """
  @spec scheduler_config() :: keyword()
  def scheduler_config do
    Application.get_env(:news_agent, @scheduler_key, [])
  end

  @doc """
  Returns SLO watcher configuration with defaults applied.
  """
  @spec slo_config() :: keyword()
  def slo_config do
    Application.get_env(:news_agent, @slo_key, [])
  end

  @doc """
  Returns the scheduler tick interval in milliseconds.
  """
  @spec tick_ms(keyword()) :: pos_integer()
  def tick_ms(overrides \\ []) do
    Keyword.get(overrides, :tick_ms, Keyword.get(scheduler_config(), :tick_ms, @default_tick_ms))
  end

  @doc """
  Returns the maximum scheduler job concurrency.
  """
  @spec max_concurrency(keyword()) :: pos_integer()
  def max_concurrency(overrides \\ []) do
    Keyword.get(
      overrides,
      :max_concurrency,
      Keyword.get(scheduler_config(), :max_concurrency, @default_max_concurrency)
    )
  end

  @doc """
  Returns the per-job timeout in milliseconds.
  """
  @spec job_timeout_ms(keyword()) :: pos_integer()
  def job_timeout_ms(overrides \\ []) do
    Keyword.get(
      overrides,
      :job_timeout_ms,
      Keyword.get(scheduler_config(), :job_timeout_ms, @default_job_timeout_ms)
    )
  end

  @doc """
  Returns the scheduling window duration in minutes.
  """
  @spec window_minutes(keyword()) :: pos_integer()
  def window_minutes(overrides \\ []) do
    Keyword.get(
      overrides,
      :window_minutes,
      Keyword.get(scheduler_config(), :window_minutes, @default_window_minutes)
    )
  end

  @doc """
  Returns the retry delay duration in minutes.
  """
  @spec retry_delay_minutes(keyword()) :: pos_integer()
  def retry_delay_minutes(overrides \\ []) do
    Keyword.get(
      overrides,
      :retry_delay_minutes,
      Keyword.get(scheduler_config(), :retry_delay_minutes, @default_retry_delay_minutes)
    )
  end

  @doc """
  Returns the scheduler job runner module.
  """
  @spec job_runner(keyword()) :: module()
  def job_runner(overrides \\ []) do
    Keyword.get(overrides, :job_runner, Keyword.get(scheduler_config(), :job_runner, @default_job_runner))
  end

  @doc """
  Returns SLO evaluation cadence in milliseconds.
  """
  @spec slo_eval_ms(keyword()) :: pos_integer()
  def slo_eval_ms(overrides \\ []) do
    Keyword.get(overrides, :slo_eval_ms, Keyword.get(slo_config(), :slo_eval_ms, @default_slo_eval_ms))
  end

  @doc """
  Returns the rolling SLO window length in minutes.
  """
  @spec slo_window_minutes(keyword()) :: pos_integer()
  def slo_window_minutes(overrides \\ []) do
    Keyword.get(
      overrides,
      :slo_window_minutes,
      Keyword.get(slo_config(), :slo_window_minutes, @default_slo_window_minutes)
    )
  end

  @doc """
  Returns the tick budget threshold in milliseconds.
  """
  @spec tick_budget_ms(keyword()) :: pos_integer()
  def tick_budget_ms(overrides \\ []) do
    Keyword.get(overrides, :tick_budget_ms, Keyword.get(slo_config(), :tick_budget_ms, @default_tick_budget_ms))
  end

  @doc """
  Returns the saturation ratio threshold.
  """
  @spec sat_ratio(keyword()) :: float()
  def sat_ratio(overrides \\ []) do
    Keyword.get(overrides, :sat_ratio, Keyword.get(slo_config(), :sat_ratio, @default_sat_ratio))
  end

  @doc """
  Returns the queue depth average threshold.
  """
  @spec depth_avg_max(keyword()) :: pos_integer()
  def depth_avg_max(overrides \\ []) do
    Keyword.get(overrides, :depth_avg_max, Keyword.get(slo_config(), :depth_avg_max, @default_depth_avg_max))
  end

  @doc """
  Returns the job p95 latency threshold in milliseconds.
  """
  @spec job_p95_max_ms(keyword()) :: pos_integer()
  def job_p95_max_ms(overrides \\ []) do
    Keyword.get(overrides, :job_p95_max_ms, Keyword.get(slo_config(), :job_p95_max_ms, @default_job_p95_max_ms))
  end

  @doc """
  Returns the cutoff rate threshold.
  """
  @spec cutoff_rate_max(keyword()) :: float()
  def cutoff_rate_max(overrides \\ []) do
    Keyword.get(overrides, :cutoff_rate_max, Keyword.get(slo_config(), :cutoff_rate_max, @default_cutoff_rate_max))
  end

  @doc """
  Returns the required consecutive breach count.
  """
  @spec breach_consecutive(keyword()) :: pos_integer()
  def breach_consecutive(overrides \\ []) do
    Keyword.get(
      overrides,
      :breach_consecutive,
      Keyword.get(slo_config(), :breach_consecutive, @default_breach_consecutive)
    )
  end
end
