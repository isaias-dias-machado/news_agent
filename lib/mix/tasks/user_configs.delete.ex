defmodule Mix.Tasks.UserConfigs.Delete do
  use Mix.Task

  @shortdoc "Deletes a user config by id"

  def run([id]) do
    Mix.Task.run("app.start")

    case parse_id(id) do
      {:ok, parsed} ->
        case NewsAgent.UserConfigs.delete(parsed) do
          :ok -> Mix.shell().info("deleted")
          {:error, reason} -> Mix.raise("delete failed: #{inspect(reason)}")
        end

      {:error, reason} ->
        Mix.raise(reason)
    end
  end

  def run(_args) do
    Mix.raise("usage: mix user_configs.delete ID")
  end

  defp parse_id(value) do
    case Integer.parse(String.trim(value)) do
      {parsed, _} when parsed > 0 -> {:ok, parsed}
      _ -> {:error, "id must be a positive integer"}
    end
  end
end
