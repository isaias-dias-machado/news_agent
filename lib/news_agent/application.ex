defmodule NewsAgent.Application do
  @moduledoc """
  Starts the NewsAgent supervision tree.

  Contract:
  - Requires `TELEGRAM_BOT_TOKEN` for the Telegram poller.
  - Runs the poller as a supervised task using long polling.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: NewsAgent.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> NewsAgent.Telegram.run() end}, restart: :permanent)
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: NewsAgent.Supervisor)
  end
end
