import Config

if Code.ensure_loaded?(Gemini) do
  config :gemini_ex, api_key: System.get_env("GEMINI_API_KEY")
end
