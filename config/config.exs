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
