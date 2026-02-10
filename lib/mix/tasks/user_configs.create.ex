defmodule Mix.Tasks.UserConfigs.Create do
  use Mix.Task

  @shortdoc "Creates a user config"

  def run(args) do
    Mix.Task.run("app.start")

    {chat_id, url_sources} = parse_args(args)

    case NewsAgent.UserConfigs.create(chat_id, url_sources) do
      {:ok, record} -> Mix.shell().info(inspect(record))
      {:error, reason} -> Mix.raise("create failed: #{inspect(reason)}")
    end
  end

  defp parse_args([]), do: {nil, []}

  defp parse_args([chat_id]) do
    {normalize_chat_id(chat_id), []}
  end

  defp parse_args([chat_id, url_sources]) do
    {normalize_chat_id(chat_id), parse_sources(url_sources)}
  end

  defp parse_args(_args) do
    Mix.raise("usage: mix user_configs.create [CHAT_ID] [URL1,URL2]")
  end

  defp normalize_chat_id(value) do
    case String.trim(value) do
      "" -> nil
      "nil" -> nil
      "null" -> nil
      "-" -> nil
      other -> other
    end
  end

  defp parse_sources(value) do
    value
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end
end
