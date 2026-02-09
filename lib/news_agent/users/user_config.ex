defmodule NewsAgent.Users.UserConfig do
  @moduledoc """
  Loads user-specific configuration for external integrations.

  The caller supplies a user id and receives the configured YouTube channel ids
  or chat reset settings. Missing or invalid configuration yields defaults so
  callers can treat absent configuration as a no-op without extra error handling.
  """

  @doc """
  Loads the configured YouTube channel ids for the given user.

  Returns an empty list when the config is missing or invalid so callers can
  treat absent configuration as a no-op.
  """
  @spec youtube_channel_ids(String.t()) :: [String.t()]
  def youtube_channel_ids(user) when is_binary(user) do
    {path, contents, data} = load_config(user)
    channel_ids = extract_channel_ids(data)

    log_config(user, path, contents, channel_ids)

    channel_ids
  end

  @doc """
  Loads the chat reset time and timezone for the given chat id.

  Falls back to the seed user when the chat config is missing or invalid.
  """
  @spec chat_reset_config(String.t()) :: %{time: Time.t(), timezone: String.t()}
  def chat_reset_config(chat_id) when is_binary(chat_id) do
    {path, contents, data} = load_config(chat_id)

    case extract_chat_reset(data) do
      {:ok, time, timezone} ->
        log_chat_config(chat_id, path, contents, time, timezone)
        %{time: time, timezone: timezone}

      :error ->
        {fallback_path, fallback_contents, fallback_data} = load_config("isaias")

        {time, timezone} =
          case extract_chat_reset(fallback_data) do
            {:ok, time, timezone} -> {time, timezone}
            :error -> {~T[00:00:00], "Etc/UTC"}
          end

        log_chat_config(chat_id, fallback_path, fallback_contents, time, timezone)
        %{time: time, timezone: timezone}
    end
  end

  @doc """
  Persists the chat id into the user configuration.
  """
  @spec persist_chat_id(String.t(), String.t()) :: :ok | {:error, term()}
  def persist_chat_id(user, chat_id) when is_binary(user) and is_binary(chat_id) do
    {path, contents, data} = load_config(user)

    case contents do
      {:error, _reason} ->
        {:error, :missing_user_config}

      {:ok, _} ->
        chat = Map.get(data, "chat", %{})
        updated = Map.put(data, "chat", Map.put(chat, "chat_id", chat_id))

        case Jason.encode(updated) do
          {:ok, json} -> File.write(path, json)
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @doc """
  Returns true when the chat id has already been persisted.
  """
  @spec chat_linked?(String.t()) :: boolean()
  def chat_linked?(chat_id) when is_binary(chat_id) do
    chat_id in linked_chat_ids()
  end

  defp config_path(user) do
    Path.join(["data", "users", "#{user}.json"])
  end

  defp load_config(user) do
    path = config_path(user)
    contents = File.read(path)
    data = decode_config(contents)
    {path, contents, data}
  end

  defp decode_config({:ok, contents}) do
    case Jason.decode(contents) do
      {:ok, data} when is_map(data) -> data
      _ -> %{}
    end
  end

  defp decode_config(_error), do: %{}

  defp linked_chat_ids do
    users_dir()
    |> Enum.flat_map(&load_chat_id/1)
  end

  defp load_chat_id(filename) do
    {_path, _contents, data} = load_config(filename)

    case get_in(data, ["chat", "chat_id"]) do
      value when is_binary(value) and value != "" -> [value]
      _ -> []
    end
  end

  defp users_dir do
    case File.ls(Path.join(["data", "users"])) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".json"))
        |> Enum.map(&Path.rootname/1)

      {:error, _} ->
        []
    end
  end

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

  defp extract_chat_reset(data) do
    with %{} = chat <- Map.get(data, "chat"),
         reset_time when is_binary(reset_time) <- Map.get(chat, "reset_time"),
         {:ok, time} <- parse_time(reset_time) do
      timezone = chat |> Map.get("timezone", "UTC") |> normalize_timezone()
      {:ok, time, timezone}
    else
      _ -> :error
    end
  end

  defp parse_time(reset_time) when is_binary(reset_time) do
    normalized =
      case String.split(reset_time, ":") do
        [hour, minute] -> "#{hour}:#{minute}:00"
        _ -> reset_time
      end

    Time.from_iso8601(normalized)
  end

  defp normalize_timezone("UTC"), do: "Etc/UTC"
  defp normalize_timezone(_timezone), do: "Etc/UTC"

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

  defp log_chat_config(chat_id, path, contents, time, timezone) do
    require Logger

    status =
      case contents do
        {:ok, _contents} -> :ok
        {:error, reason} -> {:error, reason}
      end

    Logger.debug(fn ->
      "Chat config load chat_id=#{chat_id} path=#{path} status=#{status} reset_time=#{time} timezone=#{timezone}"
    end)
  end
end
