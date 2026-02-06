defmodule NewsAgent.Gemini do
  @moduledoc """
  Boundary for Gemini text generation.

  Contract: callers provide a URL and receive a summarized string when Gemini
  returns extractable text. This module performs network calls to the Gemini API
  and requires `GEMINI_API_KEY` to be present at runtime.

  Tensions: responses depend on external availability, model behavior, and
  upstream errors; callers should expect transient failures and empty responses.
  """

  alias Gemini

  @model "gemini-2.0-flash-lite"

  @doc """
  Summarizes the content behind a URL using Gemini URL context.
  """
  @spec summarize_url(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def summarize_url(url, opts \\ []) when is_binary(url) and is_list(opts) do
    prompt =
      "Summarize the content at #{url}. Target 250-350 words in 2-4 paragraphs. Focus on the main segments and key takeaways. If you cannot access the video transcript or description, reply with: Unable to access video content for summarization."

    options =
      Keyword.merge(
        [model: @model, tools: [:url_context], max_output_tokens: 800, temperature: 0.3],
        opts
      )

    with {:ok, response} <- Gemini.generate(prompt, options),
         {:ok, summary} <- Gemini.extract_text(response) do
      {:ok, String.trim(summary)}
    else
      {:error, reason} -> {:error, reason}
      {:ok, nil} -> {:error, :empty_response}
      nil -> {:error, :empty_response}
    end
  end

  @doc """
  Summarizes transcript text with a concise multi-paragraph summary.
  """
  @spec summarize_text(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def summarize_text(transcript, opts \\ []) when is_binary(transcript) and is_list(opts) do
    prompt =
      "Summarize the following transcript. Target 250-350 words in 2-4 paragraphs. Focus on the main segments and key takeaways.\n\n" <>
        transcript

    options = Keyword.merge([model: @model, max_output_tokens: 800, temperature: 0.3], opts)

    with {:ok, response} <- Gemini.generate(prompt, options),
         {:ok, summary} <- Gemini.extract_text(response) do
      {:ok, String.trim(summary)}
    else
      {:error, reason} -> {:error, reason}
      {:ok, nil} -> {:error, :empty_response}
      nil -> {:error, :empty_response}
    end
  end
end
