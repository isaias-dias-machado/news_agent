defmodule NewsAgent.Application do
  @moduledoc """
  Starts the NewsAgent supervision tree.

  Contract:
  - Starts core runtime processes needed by the application.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: NewsAgent.TaskSupervisor}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: NewsAgent.Supervisor)
  end
end
