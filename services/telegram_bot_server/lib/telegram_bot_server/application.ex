defmodule TelegramBotServer.Application do
  @moduledoc """
  Starts the Telegram bot server runtime.

  Contract:
  - Requires `TELEGRAM_BOT_TOKEN` to poll the Telegram Bot API.
  - Exposes HTTP endpoints for workspace registration and queue polling.
  - Keeps message queues in memory and removes messages on read.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TelegramBotServer.Queue,
      TelegramBotServer.Web.Server,
      Supervisor.child_spec({Task, fn -> TelegramBotServer.Telegram.Poller.run() end},
        restart: :permanent
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: TelegramBotServer.Supervisor)
  end
end
