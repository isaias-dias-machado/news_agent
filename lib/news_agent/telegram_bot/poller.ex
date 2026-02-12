defmodule NewsAgent.TelegramBot.Poller do
  @moduledoc false

  use GenServer

  alias NewsAgent.TelegramBot
  alias NewsAgent.TelegramBot.Update

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = %{
      offset: Keyword.get(opts, :offset),
      timeout: poll_timeout_seconds(opts),
      allowed_updates: poll_allowed_updates(opts)
    }

    send(self(), :poll)
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    params =
      []
      |> maybe_put(:offset, state.offset)
      |> Keyword.put(:timeout, state.timeout)
      |> Keyword.put(:allowed_updates, state.allowed_updates)

    {offset, interval} =
      case TelegramBot.get_updates(params) do
        {:ok, updates} ->
          Enum.each(updates, &TelegramBot.enqueue_update/1)
          {next_offset(updates, state.offset), 0}

        {:error, _reason} ->
          {state.offset, 1_000}
      end

    _ = Process.send_after(self(), :poll, interval)
    {:noreply, %{state | offset: offset}}
  end

  defp next_offset([], offset), do: offset

  defp next_offset(updates, offset) do
    updates
    |> Enum.map(fn %Update{update_id: update_id} -> update_id end)
    |> Enum.max(fn -> offset end)
    |> then(&(&1 + 1))
  end

  defp poll_timeout_seconds(opts) do
    value = Keyword.get(opts, :timeout) || System.get_env("TELEGRAM_BOT_POLL_TIMEOUT")

    case value do
      int when is_integer(int) and int >= 0 -> int
      str when is_binary(str) -> parse_timeout(str)
      _ -> 30
    end
  end

  defp poll_allowed_updates(opts) do
    value = Keyword.get(opts, :allowed_updates) || System.get_env("TELEGRAM_BOT_ALLOWED_UPDATES")

    case value do
      list when is_list(list) -> list
      str when is_binary(str) and str != "" -> String.split(str, ",", trim: true)
      _ -> ["message", "edited_message", "channel_post"]
    end
  end

  defp parse_timeout(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed >= 0 -> parsed
      _ -> 30
    end
  end

  defp maybe_put(params, _key, nil), do: params
  defp maybe_put(params, key, value), do: Keyword.put(params, key, value)
end
