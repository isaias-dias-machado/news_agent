defmodule NewsAgent.YouTube.Transcription.TranscriptAPI do
  @moduledoc """
  TranscriptAPI client boundary for fetching YouTube transcripts.

  Contract: callers supply a YouTube URL or video id and receive transcript text.
  This module performs outbound HTTP calls, requires `TRANSCRIPT_API_KEY`, and
  depends on external availability and credit status. Compile-time config under
  `:news_agent, :youtube_transcription` provides retry behavior and telemetry
  is emitted for start/stop/error events.

  Tensions: network failures, rate limits, or missing transcripts surface as
  error tuples that include the failing URL; callers must handle these failures
  and avoid assuming transcripts are always available.
  """

  require Logger

  @doc """
  Fetches a plain text transcript for a YouTube URL or video id.
  """
  @spec fetch_transcript(String.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, {term(), String.t()}}
  def fetch_transcript(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    start_time = System.monotonic_time()
    telemetry_metadata = telemetry_metadata(video_url)

    :telemetry.execute(
      telemetry_event(:start),
      base_measurements(0),
      telemetry_metadata
    )

    {retries, backoff_ms} = retry_config()

    result =
      with {:ok, api_key} <- api_key(),
           {:ok, response, attempts} <-
             request_transcript(video_url, api_key, opts, retries, backoff_ms),
           {:ok, transcript} <- extract_transcript(response) do
        {:ok, transcript, attempts}
      else
        {:error, reason, attempts} -> {:error, reason, attempts}
        {:error, reason} -> {:error, reason, 0}
      end

    duration_ms = duration_ms(start_time)

    case result do
      {:ok, transcript, attempts} ->
        measurements = %{
          duration_ms: duration_ms,
          word_count: word_count(transcript),
          bytes: byte_size(transcript),
          attempts: attempts
        }

        :telemetry.execute(telemetry_event(:stop), measurements, telemetry_metadata)

        {:ok, transcript}

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

  defp request_transcript(video_url, api_key, opts, retries, backoff_ms) do
    attempt_request(video_url, api_key, opts, retries, backoff_ms, 1)
  end

  defp attempt_request(video_url, api_key, opts, retries, backoff_ms, attempt) do
    case request_transcript_once(video_url, api_key, opts) do
      {:ok, response} ->
        {:ok, response, attempt}

      {:error, reason} ->
        if transient_error?(reason) and attempt <= retries do
          log_retry(video_url, attempt, reason)
          Process.sleep(backoff_ms)
          attempt_request(video_url, api_key, opts, retries, backoff_ms, attempt + 1)
        else
          {:error, reason, attempt}
        end
    end
  end

  defp request_transcript_once(video_url, api_key, opts) do
    base_url = base_url()
    url = "#{base_url}/youtube/transcript"
    params = Keyword.merge([video_url: video_url, format: "text", include_timestamp: false], opts)
    headers = [{"authorization", "Bearer #{api_key}"}]

    case Req.get(url: url, params: params, headers: headers) do
      {:ok, %Req.Response{status: 200} = response} -> {:ok, response}
      {:ok, %Req.Response{status: status, body: body}} -> {:error, {:http_error, status, body}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_transcript(%Req.Response{body: %{"transcript" => transcript}})
       when is_binary(transcript) do
    {:ok, String.trim(transcript)}
  end

  defp extract_transcript(%Req.Response{body: %{"transcript" => transcript}})
       when is_list(transcript) do
    text =
      transcript
      |> Enum.map(&Map.get(&1, "text"))
      |> Enum.filter(&is_binary/1)
      |> Enum.join(" ")

    {:ok, String.trim(text)}
  end

  defp extract_transcript(%Req.Response{body: body}), do: {:error, {:unexpected_body, body}}

  defp retry_config do
    config = Application.get_env(:news_agent, :youtube_transcription, [])
    retries = Keyword.get(config, :retries, 2)
    backoff_ms = Keyword.get(config, :backoff_ms, 500)
    {retries, backoff_ms}
  end

  defp telemetry_event(stage) do
    [:news_agent, :youtube, :transcription, :transcript_api, stage]
  end

  defp telemetry_metadata(video_url) do
    %{url: video_url, provider: :transcript_api, model: nil, mime_type: nil}
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

  defp transient_error?({:failed_connect, _}), do: true
  defp transient_error?(:timeout), do: true
  defp transient_error?(:econnrefused), do: true
  defp transient_error?(:closed), do: true
  defp transient_error?(:nxdomain), do: true
  defp transient_error?(_), do: false

  defp log_retry(video_url, attempt, reason) do
    Logger.info(fn ->
      "event=transcription_retry provider=transcript_api url=#{video_url} attempt=#{attempt} reason=#{inspect(reason)}"
    end)
  end

  defp base_url do
    System.get_env("TRANSCRIPT_API_BASE_URL", "https://transcriptapi.com/api/v2")
  end

  defp api_key do
    {:ok, System.fetch_env!("TRANSCRIPT_API_KEY")}
  end
end
