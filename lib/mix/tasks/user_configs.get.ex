defmodule Mix.Tasks.UserConfigs.Get do
  use Mix.Task

  @shortdoc "Fetches a user config by id"

  def run([id]) do
    Mix.Task.run("app.start")

    case parse_id(id) do
      {:ok, parsed} ->
        case NewsAgent.UserConfigs.get(parsed) do
          {:ok, record} -> Mix.shell().info(inspect(record))
          :error -> Mix.raise("user config not found")
        end

      {:error, reason} ->
        Mix.raise(reason)
    end
  end

  def run(_args) do
    Mix.raise("usage: mix user_configs.get ID")
  end

  defp parse_id(value) do
    case Integer.parse(String.trim(value)) do
      {parsed, _} when parsed > 0 -> {:ok, parsed}
      _ -> {:error, "id must be a positive integer"}
    end
  end
end
