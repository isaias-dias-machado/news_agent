defmodule NewsAgent.YouTube do
  @moduledoc """
  Exposes YouTube feed queries and transcript retrieval.

  Contract: callers can fetch recent video links or request transcript text for
  a specific YouTube URL. This module performs network calls to YouTube RSS and
  the configured transcription provider selected via compile-time config
  (`:news_agent, :youtube_transcription`) and does not persist outputs.

  Tensions: external services can fail or return incomplete data; callers should
  handle error tuples and avoid assuming deterministic results. Provider modules
  emit telemetry events for transcription runs.
  """

  alias NewsAgent.YouTube.RSS
  alias NewsAgent.YouTube.Transcription.Gemini
  alias NewsAgent.YouTube.Transcription.TranscriptAPI
  alias NewsAgent.Users.UserConfig
  require Logger

  @doc """
  Returns YouTube video links published since yesterday midnight UTC for the
  configured user channels.

  Uses UTC day boundaries and returns only links so callers can decide how
  to consume them.
  """
  @spec yesterday_links_for_user(String.t()) :: [String.t()]
  def yesterday_links_for_user(user) when is_binary(user) do
    start_time = yesterday_midnight_utc()
    now = DateTime.utc_now()

    channel_ids = UserConfig.youtube_channel_ids(user)

    Logger.debug(fn ->
      "YouTube links query user=#{user} channels=#{inspect(channel_ids)} start=#{start_time} now=#{now}"
    end)

    entries = Enum.flat_map(channel_ids, &RSS.fetch_entries/1)

    Logger.debug(fn -> "YouTube links fetched user=#{user} entries=#{length(entries)}" end)

    links =
      entries
      |> Enum.filter(fn entry -> within_window?(entry.published, start_time, now) end)
      |> Enum.map(& &1.link)

    Logger.debug(fn ->
      "YouTube links filtered user=#{user} entries=#{length(entries)} links=#{length(links)}"
    end)

    links
  end

  @doc """
  Fetches transcript text or a Gemini-backed summary for a YouTube URL or video id.
  """
  @spec transcript_for_video(String.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, {term(), String.t()}}
  def transcript_for_video(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    provider = transcription_provider()

    Logger.debug(fn -> "YouTube transcript fetch url=#{video_url} provider=#{provider}" end)

    case provider do
      :gemini ->
        case Gemini.summarize_video(video_url, opts) do
          {:ok, summary} ->
            Logger.debug(fn ->
              "YouTube transcript fetched url=#{video_url} bytes=#{byte_size(summary)}"
            end)

            {:ok, summary}

          {:error, reason} ->
            Logger.debug(fn ->
              "YouTube transcript failed url=#{video_url} reason=#{inspect(reason)}"
            end)

            {:error, reason}
        end

      :transcript_api ->
        case TranscriptAPI.fetch_transcript(video_url, opts) do
          {:ok, transcript} ->
            Logger.debug(fn ->
              "YouTube transcript fetched url=#{video_url} bytes=#{byte_size(transcript)}"
            end)

            {:ok, transcript}

          {:error, reason} ->
            Logger.debug(fn ->
              "YouTube transcript failed url=#{video_url} reason=#{inspect(reason)}"
            end)

            {:error, reason}
        end
    end
  end

  defp transcription_provider do
    provider =
      :news_agent
      |> Application.get_env(:youtube_transcription, [])
      |> Keyword.get(:provider, :gemini)

    normalized =
      case provider do
        value when is_atom(value) -> value
        value when is_binary(value) -> value |> String.trim() |> String.downcase()
        _ -> :gemini
      end

    case normalized do
      :transcript_api -> :transcript_api
      :gemini -> :gemini
      "transcript_api" -> :transcript_api
      "gemini" -> :gemini
      _ -> :gemini
    end
  end

  defp within_window?(published, start_time, now) do
    DateTime.compare(published, start_time) in [:gt, :eq] and
      DateTime.compare(published, now) in [:lt, :eq]
  end

  defp yesterday_midnight_utc do
    Date.utc_today()
    |> Date.add(-1)
    |> DateTime.new!(~T[00:00:00], "Etc/UTC")
  end
end
