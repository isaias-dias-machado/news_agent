defmodule Mix.Tasks.UserConfigs.Seed do
  use Mix.Task

  @shortdoc "Seeds a default user config"

  def run(_args) do
    Mix.Task.run("app.start")

    seeds = load_seeds()
    :ok = NewsAgent.UserConfigs.clear_all()

    Enum.each(seeds, fn seed ->
      unless is_map(seed) do
        Mix.raise("seed must be a map, got: #{inspect(seed)}")
      end

      case NewsAgent.UserConfigs.create(seed) do
        {:ok, _record} ->
          :ok

        {:error, reason} ->
          Mix.raise("seed failed: #{inspect(reason)}")
      end
    end)

    Mix.shell().info("Seeded #{length(seeds)} user config(s)")
  end

  defp load_seeds do
    seeds_path = Application.app_dir(:news_agent, "priv/seeds/user_configs.exs")

    case Code.eval_file(seeds_path) do
      {seeds, _binding} when is_list(seeds) ->
        seeds

      {value, _binding} ->
        Mix.raise("seed file must return a list, got: #{inspect(value)}")
    end
  end
end
