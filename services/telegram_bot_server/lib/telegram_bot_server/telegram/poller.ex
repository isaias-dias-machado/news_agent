defmodule TelegramBotServer.Telegram.Poller do
  @moduledoc """
  Long-polling loop for Telegram updates.

  Contract:
  - Uses Telegram Bot API `getUpdates`.
  - Routes updates into workspace queues.
  """

  @type update :: map()

  @spec run() :: :ok
  def run do
    timeout = TelegramBotServer.Config.poll_timeout_seconds()
    allowed_updates = TelegramBotServer.Config.poll_allowed_updates()
    poll_next(nil, timeout, allowed_updates)
  end

  defp poll_next(offset, timeout, allowed_updates) do
    params =
      []
      |> maybe_put(:offset, offset)
      |> Keyword.put(:timeout, timeout)
      |> Keyword.put(:allowed_updates, allowed_updates)

    case TelegramBotServer.Telegram.Api.get_updates(params) do
      {:ok, updates} ->
        next_offset = handle_updates(updates, offset)
        poll_next(next_offset, timeout, allowed_updates)

      {:error, _reason} ->
        Process.sleep(1_000)
        poll_next(offset, timeout, allowed_updates)
    end
  end

  defp handle_updates([], offset), do: offset

  defp handle_updates(updates, offset) do
    Enum.each(updates, &TelegramBotServer.Queue.enqueue_update/1)

    updates
    |> Enum.map(& &1["update_id"])
    |> Enum.max(fn -> offset end)
    |> then(&(&1 + 1))
  end

  defp maybe_put(params, _key, nil), do: params
  defp maybe_put(params, key, value), do: Keyword.put(params, key, value)
end
