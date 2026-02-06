defmodule TelegramBotServer.Config do
  @moduledoc """
  Runtime configuration for the bot server.

  Contract:
  - Reads configuration from environment variables at runtime.
  - Applies safe defaults for local development.
  """

  @spec http_host() :: String.t()
  def http_host do
    System.get_env("TELEGRAM_BOT_SERVER_HOST", "0.0.0.0")
  end

  @spec http_port() :: pos_integer()
  def http_port do
    System.get_env("TELEGRAM_BOT_SERVER_PORT", "8090")
    |> String.to_integer()
  end

  @spec http_ip() :: :inet.ip_address()
  def http_ip do
    host = http_host()

    case :inet.parse_address(String.to_charlist(host)) do
      {:ok, ip} -> ip
      {:error, _} -> {0, 0, 0, 0}
    end
  end

  @spec poll_timeout_seconds() :: non_neg_integer()
  def poll_timeout_seconds do
    System.get_env("TELEGRAM_BOT_POLL_TIMEOUT", "30")
    |> String.to_integer()
    |> max(0)
  end

  @spec poll_allowed_updates() :: [String.t()]
  def poll_allowed_updates do
    System.get_env("TELEGRAM_BOT_ALLOWED_UPDATES", "message,edited_message,channel_post")
    |> String.split(",", trim: true)
  end

  @spec queue_default_limit() :: pos_integer()
  def queue_default_limit do
    System.get_env("TELEGRAM_BOT_QUEUE_LIMIT", "25")
    |> String.to_integer()
    |> max(1)
  end

  @spec queue_max_limit() :: pos_integer()
  def queue_max_limit do
    System.get_env("TELEGRAM_BOT_QUEUE_MAX_LIMIT", "200")
    |> String.to_integer()
    |> max(1)
  end
end
