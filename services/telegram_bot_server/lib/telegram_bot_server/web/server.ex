defmodule TelegramBotServer.Web.Server do
  @moduledoc """
  HTTP server for the bot API.

  Contract:
  - Starts a Plug-based HTTP server.
  - Uses `TELEGRAM_BOT_SERVER_HOST` and `TELEGRAM_BOT_SERVER_PORT`.
  """

  @spec child_spec(keyword()) :: Supervisor.child_spec()
  def child_spec(_opts) do
    Plug.Cowboy.child_spec(cowboy_options())
  end

  defp cowboy_options do
    [
      scheme: :http,
      plug: TelegramBotServer.Web.Router,
      options: [
        ip: TelegramBotServer.Config.http_ip(),
        port: TelegramBotServer.Config.http_port()
      ]
    ]
  end
end
