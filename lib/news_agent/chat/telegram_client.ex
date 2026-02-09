defmodule NewsAgent.Chat.TelegramClient do
  @moduledoc false

  require Logger

  @spec send_message(String.t(), String.t(), keyword()) :: :ok | {:error, term()}
  def send_message(chat_id, text, opts \\ []) when is_binary(chat_id) and is_binary(text) do
    with {:ok, token} <- token(opts) do
      client = Req.new(base_url: "https://api.telegram.org/bot#{token}")
      payload = %{chat_id: chat_id, text: text}

      case Req.post(client, url: "/sendMessage", json: payload) do
        {:ok, %Req.Response{status: status}} when status in 200..299 ->
          Logger.debug(fn ->
            "Chat send success chat_id=#{chat_id} text=#{truncate_text(text)}"
          end)

          :ok

        {:ok, %Req.Response{status: status, body: body}} ->
          Logger.debug(fn ->
            "Chat send error chat_id=#{chat_id} status=#{status} body=#{inspect(body)}"
          end)

          {:error, {:unexpected_status, status, body}}

        {:error, reason} ->
          Logger.debug(fn -> "Chat send error chat_id=#{chat_id} reason=#{inspect(reason)}" end)
          {:error, reason}
      end
    end
  end

  @spec get_updates(keyword()) :: {:ok, [map()]} | {:error, term()}
  def get_updates(params \\ []) when is_list(params) do
    with {:ok, token} <- token(params) do
      params = Keyword.drop(params, [:telegram_token])
      params = normalize_params(params)
      receive_timeout = receive_timeout_ms(params)
      client = Req.new(base_url: "https://api.telegram.org/bot#{token}")

      case Req.get(client, url: "/getUpdates", params: params, receive_timeout: receive_timeout) do
        {:ok, %Req.Response{status: 200, body: %{"ok" => true, "result" => result}}} ->
          {:ok, result}

        {:ok, %Req.Response{body: %{"ok" => false} = body}} ->
          {:error, {:telegram_error, body}}

        {:ok, %Req.Response{} = response} ->
          {:error, {:unexpected_response, response}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp token(opts) do
    case Keyword.get(opts, :telegram_token) do
      value when is_binary(value) and value != "" -> {:ok, value}
      _ -> {:ok, System.fetch_env!("TELEGRAM_BOT_TOKEN")}
    end
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

  defp truncate_text(text) do
    if String.length(text) > 160 do
      String.slice(text, 0, 160) <> "..."
    else
      text
    end
  end
end
