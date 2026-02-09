defmodule NewsAgent.Gemini do
  @moduledoc """
  Boundary for Gemini text generation.

  Contract: callers provide text or a URL and receive a summarized string when
  Gemini returns extractable text. This module performs network calls to the
  Gemini API, requires `GEMINI_API_KEY`, and honors `GEMINI_VIDEO_MODEL` and
  `GEMINI_VIDEO_MIME_TYPE` for video inputs.

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

  @doc """
  Summarizes video content using Gemini multimodal file inputs.

  Targets 900-1100 words in 4-6 paragraphs and may request a continuation when
  the initial response is short or incomplete.
  """
  @spec summarize_video_url(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def summarize_video_url(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    prompt =
      "Summarize the video content. Target 900-1100 words in 4-6 paragraphs. Focus on the main segments and key takeaways. If you cannot access the video content, reply with: Unable to access video content for summarization."

    {mime_type, options} = Keyword.pop(opts, :mime_type, video_mime_type())

    options =
      Keyword.merge(
        [model: video_model(), max_output_tokens: 2800, temperature: 0.3],
        options
      )

    content = [%{file_uri: video_url, mime_type: mime_type}, prompt]

    with {:ok, response} <- Gemini.generate(content, options),
         {:ok, summary} <- Gemini.extract_text(response) do
      summary = String.trim(summary)

      if needs_continuation?(summary) do
        continue_summary(summary, options)
      else
        {:ok, summary}
      end
    else
      {:error, reason} -> {:error, reason}
      {:ok, nil} -> {:error, :empty_response}
      nil -> {:error, :empty_response}
    end
  end

  defp continue_summary(summary, options) do
    continuation_prompt =
      "Continue the summary to reach 900-1100 words total. Keep 4-6 paragraphs overall and do not repeat sentences. Previous summary:\n\n" <>
        summary

    case Gemini.generate(continuation_prompt, options) do
      {:ok, response} ->
        case Gemini.extract_text(response) do
          {:ok, continuation} ->
            continuation = String.trim(continuation)

            if continuation == "" do
              {:ok, summary}
            else
              {:ok, String.trim(summary <> " " <> continuation)}
            end

          _ ->
            {:ok, summary}
        end

      _ ->
        {:ok, summary}
    end
  end

  defp needs_continuation?(summary) do
    word_count =
      summary
      |> String.split(~r/\s+/, trim: true)
      |> length()

    word_count < 900 or not ends_with_terminator?(summary)
  end

  defp ends_with_terminator?(summary) do
    case String.trim(summary) do
      "" ->
        false

      text ->
        String.ends_with?(text, [".", "!", "?"])
    end
  end

  defp video_model do
    case System.get_env("GEMINI_VIDEO_MODEL") do
      value when is_binary(value) and value != "" -> value
      _ -> "gemini-3-flash-preview"
    end
  end

  defp video_mime_type do
    case System.get_env("GEMINI_VIDEO_MIME_TYPE") do
      value when is_binary(value) and value != "" -> value
      _ -> "video/mp4"
    end
  end
end
