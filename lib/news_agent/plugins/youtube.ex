defmodule NewsAgent.Plugins.YouTube do
  @moduledoc """
  Exposes YouTube feed queries and summaries for user-driven workflows.

  Contract: callers can fetch recent video links or request a summary for a
  specific YouTube URL. This module performs network calls to YouTube RSS and
  Gemini, writes summaries to disk, and requires `GEMINI_API_KEY` for summaries.

  Tensions: external services can fail or return incomplete data, and file
  system writes can fail due to permissions or IO errors. Callers should handle
  error tuples and avoid assuming deterministic results.
  """

  import Bitwise

  alias NewsAgent.Gemini
  alias NewsAgent.Plugins.YouTube.RSS
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
  Summarizes a YouTube URL and writes the summary to the user data directory.

  Returns `{:ok, path}` when the summary is stored successfully.
  """
  @spec summarize_video(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def summarize_video(url, opts \\ []) when is_binary(url) and is_list(opts) do
    normalized_url = normalize_youtube_url(url)

    Logger.debug(fn -> "YouTube summary start url=#{normalized_url}" end)

    case Gemini.summarize_url(normalized_url, opts) do
      {:ok, summary} ->
        case write_summary(summary) do
          {:ok, path} ->
            Logger.debug(fn ->
              "YouTube summary stored url=#{normalized_url} path=#{path} bytes=#{byte_size(summary)}"
            end)

            {:ok, path}

          {:error, reason} ->
            Logger.debug(fn ->
              "YouTube summary write failed url=#{normalized_url} reason=#{inspect(reason)}"
            end)

            {:error, reason}
        end

      {:error, reason} ->
        Logger.debug(fn ->
          "YouTube summary failed url=#{normalized_url} reason=#{inspect(reason)}"
        end)

        {:error, reason}
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

  defp write_summary(summary) when is_binary(summary) do
    date = Date.utc_today() |> Date.to_iso8601()
    uuid = uuid4()
    dir = Path.join(["data", "users", "isaias", date])
    path = Path.join(dir, "#{uuid}.txt")

    try do
      File.mkdir_p!(dir)
    rescue
      exception -> {:error, exception}
    else
      _ ->
        case File.write(path, summary) do
          :ok ->
            Logger.debug(fn ->
              "YouTube summary file write path=#{path} bytes=#{byte_size(summary)}"
            end)

            {:ok, path}

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp normalize_youtube_url(url) do
    uri = URI.parse(url)
    host = uri.host || ""

    cond do
      host in ["youtu.be"] ->
        path = uri.path || ""
        video_id = String.trim_leading(path, "/")

        if video_id == "" do
          url
        else
          "https://www.youtube.com/watch?v=#{video_id}"
        end

      host in ["www.youtube.com", "youtube.com", "m.youtube.com"] ->
        video_id = video_id_from_query(uri.query)

        if is_binary(video_id) do
          "https://www.youtube.com/watch?v=#{video_id}"
        else
          url
        end

      true ->
        url
    end
  end

  defp video_id_from_query(nil), do: nil

  defp video_id_from_query(query) when is_binary(query) do
    query
    |> URI.decode_query()
    |> Map.get("v")
  end

  defp uuid4 do
    bytes = :crypto.strong_rand_bytes(16)
    list = :binary.bin_to_list(bytes)

    list =
      list
      |> List.update_at(6, fn byte -> (byte &&& 0x0F) ||| 0x40 end)
      |> List.update_at(8, fn byte -> (byte &&& 0x3F) ||| 0x80 end)

    hex = Base.encode16(:binary.list_to_bin(list), case: :lower)

    <<p1::binary-size(8), p2::binary-size(4), p3::binary-size(4), p4::binary-size(4),
      p5::binary-size(12)>> = hex

    "#{p1}-#{p2}-#{p3}-#{p4}-#{p5}"
  end
end
