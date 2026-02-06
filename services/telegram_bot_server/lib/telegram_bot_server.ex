defmodule TelegramBotServer do
  @moduledoc """
  Telegram bot server that polls updates and routes them to workspace queues.

  Contract:
  - Polls the Telegram Bot API using `TELEGRAM_BOT_TOKEN`.
  - Exposes an HTTP API for workspace registration and queue polling.
  - Keeps all routing state in memory.
  """
end
