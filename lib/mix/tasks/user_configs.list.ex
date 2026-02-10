defmodule Mix.Tasks.UserConfigs.List do
  use Mix.Task

  @shortdoc "Lists user configs"

  def run(_args) do
    Mix.Task.run("app.start")

    case NewsAgent.UserConfigs.list() do
      [] ->
        Mix.shell().info("No user configs found")

      records ->
        Enum.each(records, fn record ->
          Mix.shell().info(inspect(record))
        end)
    end
  end
end
