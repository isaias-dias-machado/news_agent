defmodule NewsAgent.Telegram.Api do
  @moduledoc """
  Telegram Bot API integration wrapper.

  Contract:
  - Requires `TELEGRAM_BOT_TOKEN` at runtime.
  - Handles request/response wrapping for `getUpdates` and `sendMessage`.
  - Returns Telegram error payloads as tagged tuples.
  """

  @type chat_id :: integer() | String.t()
  @type update :: map()
  require Logger

  @spec get_updates(keyword()) :: {:ok, [update()]} | {:error, term()}
  def get_updates(params \\ []) do
    token = bot_token!()
    url = "https://api.telegram.org/bot#{token}/getUpdates"
    params = normalize_params(params)
    start_time = System.monotonic_time()
    endpoint = "getUpdates"

    receive_timeout = receive_timeout_ms(params)

    Logger.debug(fn ->
      "Telegram API request endpoint=#{endpoint} payload=#{inspect(params)}"
    end)

    case Req.get(url: url, params: params, receive_timeout: receive_timeout) do
      {:ok, %Req.Response{status: 200, body: %{"ok" => true, "result" => result}} = response} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(response)}"
        end)

        {:ok, result}

      {:ok, %Req.Response{body: %{"ok" => false} = body} = response} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(response)}"
        end)

        {:error, {:telegram_error, body}}

      {:ok, %Req.Response{} = response} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(response)}"
        end)

        {:error, {:unexpected_response, response}}

      {:error, error} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(error)}"
        end)

        {:error, error}
    end
  end

  @spec send_message(chat_id(), String.t()) :: :ok | {:error, term()}
  def send_message(chat_id, text) do
    token = bot_token!()
    url = "https://api.telegram.org/bot#{token}/sendMessage"
    start_time = System.monotonic_time()
    endpoint = "sendMessage"
    payload = %{chat_id: chat_id, text: text}

    Logger.debug(fn ->
      "Telegram API request endpoint=#{endpoint} payload=#{inspect(payload)}"
    end)

    case Req.post(url: url, json: payload) do
      {:ok, %Req.Response{status: 200, body: %{"ok" => true}} = response} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(response)}"
        end)

        :ok

      {:ok, %Req.Response{body: %{"ok" => false} = body} = response} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(response)}"
        end)

        {:error, {:telegram_error, body}}

      {:ok, %Req.Response{} = response} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(response)}"
        end)

        {:error, {:unexpected_response, response}}

      {:error, error} ->
        Logger.debug(fn ->
          "Telegram API response endpoint=#{endpoint} duration_ms=#{duration_ms(start_time)} response=#{inspect(error)}"
        end)

        {:error, error}
    end
  end

  defp bot_token! do
    System.fetch_env!("TELEGRAM_BOT_TOKEN")
  end

  defp normalize_params(params) do
    Keyword.update(params, :allowed_updates, nil, &encode_allowed_updates/1)
  end

  defp receive_timeout_ms(params) do
    timeout = Keyword.get(params, :timeout, 0)
    timeout_seconds = max(timeout, 0)

    (timeout_seconds + 5) * 1_000
  end

  defp encode_allowed_updates(value) when is_list(value), do: Jason.encode!(value)
  defp encode_allowed_updates(value), do: value

  defp duration_ms(start_time) do
    System.monotonic_time()
    |> Kernel.-(start_time)
    |> System.convert_time_unit(:native, :millisecond)
  end
end
