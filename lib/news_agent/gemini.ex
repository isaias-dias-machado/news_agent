defmodule NewsAgent.Gemini do
  @moduledoc """
  Boundary for Gemini text generation.

  Contract: callers provide text or a URL and receive a summarized string when
  Gemini returns extractable text. This module performs network calls to the
  Gemini API, requires `GEMINI_API_KEY`, and honors compile-time video defaults
  under `:news_agent, :gemini_video` while emitting telemetry for video runs.

  Tensions: responses depend on external availability, model behavior, and
  upstream errors; callers should expect transient failures and empty responses.
  """

  alias Gemini
  require Logger

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

  Targets the configured word range and accepts the summary as returned.
  """
  @spec summarize_video_url(String.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, {term(), String.t()}}
  def summarize_video_url(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    config = video_config()
    prompt = video_prompt(config.target_words)

    {mime_type, options} = Keyword.pop(opts, :mime_type, config.mime_type)

    options =
      Keyword.merge(
        [model: config.model, max_output_tokens: config.max_output_tokens, temperature: 0.3],
        options
      )

    content = [%{file_uri: video_url, mime_type: mime_type}, prompt]
    start_time = System.monotonic_time()
    telemetry_metadata = telemetry_metadata(video_url, options[:model], mime_type)

    :telemetry.execute(
      telemetry_event(:start),
      base_measurements(0),
      telemetry_metadata
    )

    result = generate_video_summary(video_url, content, options, config)
    duration_ms = duration_ms(start_time)

    case result do
      {:ok, summary, attempts} ->
        measurements = %{
          duration_ms: duration_ms,
          word_count: word_count(summary),
          bytes: byte_size(summary),
          attempts: attempts
        }

        :telemetry.execute(telemetry_event(:stop), measurements, telemetry_metadata)

        {:ok, summary}

      {:error, reason, attempts} ->
        measurements = %{
          duration_ms: duration_ms,
          word_count: 0,
          bytes: 0,
          attempts: attempts
        }

        :telemetry.execute(
          telemetry_event(:error),
          measurements,
          Map.put(telemetry_metadata, :reason, reason)
        )

        {:error, {reason, video_url}}
    end
  end

  defp generate_video_summary(video_url, content, options, config) do
    case generate_with_retry(content, options, video_url, config) do
      {:ok, response, attempts} ->
        case Gemini.extract_text(response) do
          {:ok, summary} when is_binary(summary) ->
            summary = String.trim(summary)

            if summary == "" do
              {:error, :empty_response, attempts}
            else
              {:ok, summary, attempts}
            end

          {:ok, nil} ->
            {:error, :empty_response, attempts}

          nil ->
            {:error, :empty_response, attempts}

          {:error, reason} ->
            {:error, reason, attempts}
        end

      {:error, reason, attempts} ->
        {:error, reason, attempts}
    end
  end

  defp generate_with_retry(payload, options, video_url, config) do
    do_generate_with_retry(payload, options, video_url, config.retries, config.backoff_ms, 1)
  end

  defp do_generate_with_retry(payload, options, video_url, retries, backoff_ms, attempt) do
    case Gemini.generate(payload, options) do
      {:ok, response} ->
        {:ok, response, attempt}

      {:error, reason} ->
        if transient_error?(reason) and attempt <= retries do
          log_retry(video_url, attempt, reason)
          Process.sleep(backoff_ms)
          do_generate_with_retry(payload, options, video_url, retries, backoff_ms, attempt + 1)
        else
          {:error, reason, attempt}
        end
    end
  end

  defp video_config do
    config = Application.get_env(:news_agent, :gemini_video, [])

    %{
      model: Keyword.get(config, :model, "gemini-3-flash-preview"),
      mime_type: Keyword.get(config, :mime_type, "video/mp4"),
      max_output_tokens: Keyword.get(config, :max_output_tokens, 2800),
      target_words: Keyword.get(config, :target_words, "900-1100"),
      retries: Keyword.get(config, :retries, 2),
      backoff_ms: Keyword.get(config, :backoff_ms, 500)
    }
  end

  defp video_prompt(target_words) do
    "Summarize the video content. Target #{target_words} words in 4-6 paragraphs. Focus on the main segments and key takeaways. If you cannot access the video content, reply with: Unable to access video content for summarization."
  end

  defp telemetry_event(stage) do
    [:news_agent, :youtube, :transcription, :gemini, stage]
  end

  defp telemetry_metadata(video_url, model, mime_type) do
    %{url: video_url, provider: :gemini, model: model, mime_type: mime_type}
  end

  defp base_measurements(attempts) do
    %{
      duration_ms: 0,
      word_count: 0,
      bytes: 0,
      attempts: attempts
    }
  end

  defp duration_ms(start_time) do
    System.monotonic_time()
    |> Kernel.-(start_time)
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp word_count(text) do
    text
    |> String.split(~r/\s+/, trim: true)
    |> length()
  end

  defp transient_error?({:http_error, status, _body}) when is_integer(status) do
    status == 429 or status >= 500
  end

  defp transient_error?(%{reason: reason}) do
    transient_error?(reason)
  end

  defp transient_error?(%{status: status}) when is_integer(status) do
    status == 429 or status >= 500
  end

  defp transient_error?({:failed_connect, _}), do: true
  defp transient_error?(:timeout), do: true
  defp transient_error?(:econnrefused), do: true
  defp transient_error?(:closed), do: true
  defp transient_error?(:nxdomain), do: true
  defp transient_error?(_), do: false

  defp log_retry(video_url, attempt, reason) do
    Logger.info(fn ->
      "event=transcription_retry provider=gemini url=#{video_url} attempt=#{attempt} reason=#{inspect(reason)}"
    end)
  end
end
