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

  alias NewsAgent.Gemini.Client
  require Logger

  @model "gemini-2.0-flash-lite"

  @doc """
  Summarizes the content behind a URL using Gemini URL context.
  """
  @spec summarize_url(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def summarize_url(url, opts \\ []) when is_binary(url) and is_list(opts) do
    _ = System.fetch_env!("GEMINI_API_KEY")

    prompt =
      "Summarize the content at #{url}. Target 250-350 words in 2-4 paragraphs. Focus on the main segments and key takeaways. If you cannot access the video transcript or description, reply with: Unable to access video content for summarization."

    options = Keyword.merge([model: @model, max_output_tokens: 800, temperature: 0.3], opts)
    payload = build_payload(prompt, options, grounding_tools(opts, true), nil)

    with {:ok, response} <- Client.generate(payload, client_options(options, opts)),
         {:ok, summary} <- Client.extract_text(response) do
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
    _ = System.fetch_env!("GEMINI_API_KEY")

    prompt =
      "Summarize the following transcript. Target 250-350 words in 2-4 paragraphs. Focus on the main segments and key takeaways.\n\n" <>
        transcript

    options = Keyword.merge([model: @model, max_output_tokens: 800, temperature: 0.3], opts)
    payload = build_payload(prompt, options, grounding_tools(opts, false), nil)

    with {:ok, response} <- Client.generate(payload, client_options(options, opts)),
         {:ok, summary} <- Client.extract_text(response) do
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
    _ = System.fetch_env!("GEMINI_API_KEY")

    config = video_config()
    prompt = video_prompt(config.target_words)

    {mime_type, options} = Keyword.pop(opts, :mime_type, config.mime_type)
    timeout_ms = Keyword.get(opts, :timeout_ms)

    options =
      Keyword.merge(
        [
          model: config.model,
          max_output_tokens: config.max_output_tokens,
          temperature: 0.3,
          timeout_ms: timeout_ms
        ],
        options
      )

    content = [
      %{"fileData" => %{"mimeType" => mime_type, "fileUri" => video_url}},
      %{"text" => prompt}
    ]

    start_time = System.monotonic_time()
    telemetry_metadata = telemetry_metadata(video_url, options[:model], mime_type)

    :telemetry.execute(
      telemetry_event(:start),
      base_measurements(0),
      telemetry_metadata
    )

    request_id = build_request_id()
    result = generate_video_summary(video_url, content, options, config, request_id)
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

  defp generate_video_summary(video_url, content, options, config, request_id) do
    case generate_with_retry(content, options, video_url, config, request_id) do
      {:ok, response, attempts} ->
        case Client.extract_text(response) do
          {:ok, summary} when is_binary(summary) ->
            summary = String.trim(summary)

            if summary == "" do
              {:error, :empty_response, attempts}
            else
              {:ok, summary, attempts}
            end

          {:ok, nil} ->
            {:error, :empty_response, attempts}

          {:error, reason} ->
            {:error, reason, attempts}
        end

      {:error, reason, attempts} ->
        {:error, reason, attempts}
    end
  end

  defp generate_with_retry(parts, options, video_url, config, request_id) do
    do_generate_with_retry(
      parts,
      options,
      video_url,
      config.retries,
      config.backoff_ms,
      request_id,
      1
    )
  end

  defp do_generate_with_retry(
         parts,
         options,
         video_url,
         retries,
         backoff_ms,
         request_id,
         attempt
       ) do
    start_time = System.monotonic_time()

    request_payload = build_payload(parts, options, grounding_tools([], false), nil)

    case Client.generate(request_payload, client_options(options, [])) do
      {:ok, response} ->
        _ = duration_ms(start_time)
        {:ok, response, attempt}

      {:error, reason} ->
        duration_ms = duration_ms(start_time)

        metadata = %{
          request_id: request_id,
          model: options[:model],
          attempt: attempt,
          timeout_ms: nil,
          duration_ms: duration_ms,
          url: video_url
        }

        if retryable?(reason) and attempt <= retries do
          log_retry(:youtube_transcription, metadata, reason)
          Process.sleep(retry_backoff_ms(reason, backoff_ms))

          do_generate_with_retry(
            parts,
            options,
            video_url,
            retries,
            backoff_ms,
            request_id,
            attempt + 1
          )
        else
          log_failure(:youtube_transcription, metadata, reason)
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

  @spec generation_config(Keyword.t()) :: map()
  def generation_config(options) when is_list(options) do
    %{
      "temperature" => Keyword.get(options, :temperature, 0.3),
      "maxOutputTokens" => Keyword.get(options, :max_output_tokens, 800),
      "topP" => Keyword.get(options, :top_p, 0.95)
    }
  end

  @spec grounding_tools(Keyword.t(), boolean()) :: [map()] | nil
  def grounding_tools(opts, default) when is_list(opts) and is_boolean(default) do
    enabled = Keyword.get(opts, :grounding?, default)

    if enabled do
      [%{"google_search" => %{}}]
    else
      nil
    end
  end

  @spec build_request_id() :: String.t()
  def build_request_id do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16(case: :lower)
  end

  @spec retryable?(term()) :: boolean()
  def retryable?(reason) do
    case extract_status(reason) do
      status when status == 429 or status >= 500 ->
        true

      status when is_integer(status) ->
        false

      nil ->
        case unwrap_reason(reason) do
          :timeout -> true
          {:failed_connect, _} -> true
          :econnrefused -> true
          :closed -> true
          :nxdomain -> true
          _ -> false
        end
    end
  end

  @spec log_retry(atom() | String.t(), map(), term()) :: :ok
  def log_retry(context, metadata, reason) do
    level = if timeout_error?(reason), do: :warning, else: :info
    log_event(:gemini_retry, level, context, metadata, reason)
  end

  @spec log_failure(atom() | String.t(), map(), term()) :: :ok
  def log_failure(context, metadata, reason) do
    log_event(:gemini_failure, failure_level(reason), context, metadata, reason)
  end

  @spec retry_backoff_ms(term(), pos_integer()) :: pos_integer()
  def retry_backoff_ms(reason, default_backoff_ms) do
    case retry_after_ms(reason) do
      value when is_integer(value) and value > 0 -> value
      _ -> default_backoff_ms
    end
  end

  @spec extract_status(term()) :: integer() | nil
  def extract_status({:http_error, status, _body}) when is_integer(status), do: status
  def extract_status(%{status: status}) when is_integer(status), do: status
  def extract_status(%{reason: reason}), do: extract_status(reason)
  def extract_status(_), do: nil

  @spec truncate_reason(term()) :: String.t()
  def truncate_reason({:http_error, status, body}) do
    "http_error status=#{status} body=#{truncate_body(body)}"
  end

  def truncate_reason({:http_error, status, body, _headers}) do
    "http_error status=#{status} body=#{truncate_body(body)}"
  end

  def truncate_reason(%{status: status, body: body}) when is_integer(status) do
    "http_error status=#{status} body=#{truncate_body(body)}"
  end

  def truncate_reason(%{status: status, body: body, headers: _headers}) when is_integer(status) do
    "http_error status=#{status} body=#{truncate_body(body)}"
  end

  def truncate_reason(%{reason: reason}) do
    truncate_reason(reason)
  end

  def truncate_reason(reason) when is_binary(reason) do
    truncate_binary(reason, 200)
  end

  def truncate_reason(reason) do
    inspect(reason, limit: 10, printable_limit: 200)
  end

  defp log_event(event, level, context, metadata, reason) do
    base_metadata = %{
      request_id: Map.get(metadata, :request_id),
      model: Map.get(metadata, :model),
      attempt: Map.get(metadata, :attempt),
      timeout_ms: Map.get(metadata, :timeout_ms),
      duration_ms: Map.get(metadata, :duration_ms),
      status: extract_status(reason),
      reason: truncate_reason(reason)
    }

    merged_metadata = Map.merge(metadata, base_metadata)

    Logger.log(level, fn ->
      "event=#{event} context=#{context}#{format_metadata(merged_metadata)}"
    end)
  end

  defp format_metadata(metadata) do
    required_keys = [:request_id, :model, :attempt, :timeout_ms, :duration_ms, :status, :reason]

    required =
      required_keys
      |> Enum.map(fn key -> " #{key}=#{format_value(Map.get(metadata, key))}" end)
      |> Enum.join()

    extras =
      metadata
      |> Map.drop(required_keys)
      |> Enum.map(fn {key, value} -> " #{key}=#{format_value(value)}" end)
      |> Enum.join()

    required <> extras
  end

  defp format_value(value) when is_binary(value) do
    truncate_binary(value, 200)
  end

  defp format_value(value) do
    inspect(value, limit: 10, printable_limit: 200)
  end

  defp truncate_body(body) when is_binary(body) do
    truncate_binary(body, 200)
  end

  defp truncate_body(body) do
    inspect(body, limit: 10, printable_limit: 200)
  end

  defp truncate_binary(value, limit) do
    if byte_size(value) > limit do
      binary_part(value, 0, limit) <> "..."
    else
      value
    end
  end

  defp failure_level(reason) do
    cond do
      paging_error?(reason) -> :error
      timeout_error?(reason) -> :warning
      retryable?(reason) -> :info
      true -> :warning
    end
  end

  defp paging_error?(reason) do
    case extract_status(reason) do
      status when status in [400, 401, 403, 422] -> true
      _ -> false
    end
  end

  defp timeout_error?(reason) do
    case unwrap_reason(reason) do
      :timeout -> true
      _ -> false
    end
  end

  defp unwrap_reason(%{reason: reason}), do: unwrap_reason(reason)
  defp unwrap_reason(reason), do: reason

  defp retry_after_ms(reason) do
    case unwrap_reason(reason) do
      {:http_error, 429, _body, headers} -> retry_after_from_headers(headers)
      %{status: 429, headers: headers} -> retry_after_from_headers(headers)
      _ -> nil
    end
  end

  defp retry_after_from_headers(headers) when is_list(headers) do
    case Enum.find(headers, fn {key, _value} -> normalize_header(key) == "retry-after" end) do
      {_, value} -> parse_retry_after(value)
      _ -> nil
    end
  end

  defp retry_after_from_headers(_), do: nil

  defp parse_retry_after(value) when is_binary(value) do
    case Integer.parse(String.trim(value)) do
      {seconds, _} when seconds > 0 -> seconds * 1_000
      _ -> nil
    end
  end

  defp parse_retry_after(_), do: nil

  defp normalize_header(key) when is_binary(key), do: String.downcase(key)
  defp normalize_header(key) when is_atom(key), do: key |> Atom.to_string() |> String.downcase()
  defp normalize_header(_), do: ""

  defp build_payload(prompt_or_parts, options, tools, system_instruction) do
    contents = build_contents(prompt_or_parts)

    payload = %{
      "contents" => contents,
      "generationConfig" => generation_config(options)
    }

    payload
    |> maybe_put("tools", tools)
    |> maybe_put("systemInstruction", build_system_instruction(system_instruction))
  end

  defp build_contents(prompt) when is_binary(prompt) do
    [
      %{
        "role" => "user",
        "parts" => [%{"text" => prompt}]
      }
    ]
  end

  defp build_contents(parts) when is_list(parts) do
    [
      %{
        "role" => "user",
        "parts" => parts
      }
    ]
  end

  defp build_system_instruction(nil), do: nil

  defp build_system_instruction(instruction) when is_binary(instruction) do
    %{
      "parts" => [%{"text" => instruction}]
    }
  end

  defp maybe_put(payload, _key, nil), do: payload
  defp maybe_put(payload, key, value), do: Map.put(payload, key, value)

  defp client_options(options, opts) do
    model = Keyword.get(options, :model, @model)

    timeout_ms =
      case Keyword.get(opts, :timeout_ms) do
        value when is_integer(value) and value > 0 -> value
        _ -> Keyword.get(options, :timeout_ms, 60_000)
      end

    [model: model, timeout_ms: timeout_ms]
  end
end
