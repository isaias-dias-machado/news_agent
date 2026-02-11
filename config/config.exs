import Config

config :news_agent, :youtube_transcription,
  provider: :gemini,
  retries: 2,
  backoff_ms: 500

config :news_agent, :gemini_video,
  retries: 2,
  backoff_ms: 500,
  model: "gemini-3-flash-preview",
  mime_type: "video/mp4",
  max_output_tokens: 2800,
  target_words: "900-1100"

config :news_agent, :scheduler,
  tick_ms: 60_000,
  max_concurrency: 4,
  job_timeout_ms: 120_000,
  window_minutes: 60,
  retry_delay_minutes: 10,
  job_runner: NewsAgent.Scheduler.JobRunner

config :news_agent, :scheduler_slo,
  slo_eval_ms: 60_000,
  slo_window_minutes: 15,
  tick_budget_ms: 300,
  sat_ratio: 0.8,
  depth_avg_max: 50,
  job_p95_max_ms: 30_000,
  cutoff_rate_max: 0.2,
  breach_consecutive: 3
