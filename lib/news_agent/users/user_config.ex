defmodule NewsAgent.Users.UserConfig do
  @moduledoc """
  Loads user-specific configuration for external integrations.

  The caller supplies a user id and receives the configured YouTube channel ids.
  Missing or invalid configuration yields an empty list so callers can treat it
  as a no-op without extra error handling.
  """

  @doc """
  Loads the configured YouTube channel ids for the given user.

  Returns an empty list when the config is missing or invalid so callers can
  treat absent configuration as a no-op.
  """
  @spec youtube_channel_ids(String.t()) :: [String.t()]
  def youtube_channel_ids(user) when is_binary(user) do
    path = config_path(user)
    contents = File.read(path)
    channel_ids = contents |> decode_config() |> extract_channel_ids()

    log_config(user, path, contents, channel_ids)

    channel_ids
  end

  defp config_path(user) do
    Path.join(["data", "users", "#{user}.json"])
  end

  defp decode_config({:ok, contents}) do
    case Jason.decode(contents) do
      {:ok, data} when is_map(data) -> data
      _ -> %{}
    end
  end

  defp decode_config(_error), do: %{}

  defp extract_channel_ids(data) do
    data
    |> Map.get("youtube", [])
    |> Enum.reduce([], fn entry, acc ->
      case Map.get(entry, "channel_id") do
        channel_id when is_binary(channel_id) -> [channel_id | acc]
        _ -> acc
      end
    end)
    |> Enum.reverse()
  end

  defp log_config(user, path, contents, channel_ids) do
    require Logger

    status =
      case contents do
        {:ok, _contents} -> :ok
        {:error, reason} -> {:error, reason}
      end

    Logger.debug(fn ->
      "User config load user=#{user} path=#{path} status=#{status} channels=#{inspect(channel_ids)}"
    end)
  end
end
