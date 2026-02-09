defmodule NewsAgent.Chat.LLM do
  @moduledoc false

  @spec generate(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def generate(prompt, opts \\ []) when is_binary(prompt) do
    provider = Keyword.get(opts, :provider, default_provider())
    provider.generate(prompt, opts)
  end

  defp default_provider do
    Application.get_env(:news_agent, :chat_llm_provider, NewsAgent.Chat.LLM.Gemini)
  end
end
