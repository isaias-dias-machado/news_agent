defmodule NewsAgent.Plugins.YouTube do
  @moduledoc """
  Exposes YouTube feed queries for user-driven channel configuration.

  The caller provides a user id and receives links for entries published since
  yesterday at UTC midnight through the current time. The function uses UTC
  day boundaries and returns only links, leaving callers to decide how to
  consume them.
  """

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
