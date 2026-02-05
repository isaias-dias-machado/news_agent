defmodule NewsAgent.Telegram do
  @moduledoc """
  Minimal Telegram Bot API client with a long-polling loop.

  Contract:
  - Requires `TELEGRAM_BOT_TOKEN` at runtime.
  - Uses Telegram `getUpdates` for long polling and `sendMessage` for replies.
  - The poller is a blocking loop intended for a single process.
  """

  @type chat_id :: integer() | String.t()
  @type update :: map()

  @spec run() :: :ok
  def run do
    poll_forever(&handle_hello/1)
  end

  @spec send_hello(chat_id()) :: :ok | {:error, term()}
  def send_hello(chat_id) when is_integer(chat_id) do
    send_message(chat_id, "Hello world")
  end

  @spec latest_chat_ids() :: [chat_id()]
  def latest_chat_ids do
    case get_updates(timeout: 0, limit: 10) do
      {:ok, updates} ->
        updates
        |> Enum.map(&extract_chat_id/1)
        |> Enum.reject(&is_nil/1)
        |> Enum.uniq()

      {:error, _reason} ->
        []
    end
  end

  @spec poll_forever((update() -> any()), keyword()) :: :ok
  def poll_forever(handler, opts \\ []) when is_function(handler, 1) do
    timeout = Keyword.get(opts, :timeout, 30)
    allowed_updates = Keyword.get(opts, :allowed_updates, ["message"])

    poll_next(nil, handler, timeout, allowed_updates)
  end

  @spec get_updates(keyword()) :: {:ok, [update()]} | {:error, term()}
  def get_updates(params \\ []) do
    token = bot_token!()
    url = "https://api.telegram.org/bot#{token}/getUpdates"
    params = normalize_params(params)

    case Req.get(url: url, params: params) do
      {:ok, %Req.Response{status: 200, body: %{"ok" => true, "result" => result}}} ->
        {:ok, result}

      {:ok, %Req.Response{body: %{"ok" => false} = body}} ->
        {:error, {:telegram_error, body}}

      {:ok, %Req.Response{} = response} ->
        {:error, {:unexpected_response, response}}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec send_message(chat_id(), String.t()) :: :ok | {:error, term()}
  def send_message(chat_id, text) do
    token = bot_token!()
    url = "https://api.telegram.org/bot#{token}/sendMessage"

    case Req.post(url: url, json: %{chat_id: chat_id, text: text}) do
      {:ok, %Req.Response{status: 200, body: %{"ok" => true}}} ->
        :ok

      {:ok, %Req.Response{body: %{"ok" => false} = body}} ->
        {:error, {:telegram_error, body}}

      {:ok, %Req.Response{} = response} ->
        {:error, {:unexpected_response, response}}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec bot_token!() :: String.t()
  def bot_token! do
    System.fetch_env!("TELEGRAM_BOT_TOKEN")
  end

  defp poll_next(offset, handler, timeout, allowed_updates) do
    params =
      []
      |> maybe_put(:offset, offset)
      |> Keyword.put(:timeout, timeout)
      |> Keyword.put(:allowed_updates, allowed_updates)

    case get_updates(params) do
      {:ok, updates} ->
        next_offset = handle_updates(updates, handler, offset)
        poll_next(next_offset, handler, timeout, allowed_updates)

      {:error, _reason} ->
        Process.sleep(1_000)
        poll_next(offset, handler, timeout, allowed_updates)
    end
  end

  defp handle_updates([], _handler, offset), do: offset

  defp handle_updates(updates, handler, offset) do
    Enum.each(updates, handler)

    updates
    |> Enum.map(& &1["update_id"])
    |> Enum.max(fn -> offset end)
    |> then(&(&1 + 1))
  end

  defp handle_hello(%{"message" => %{"chat" => %{"id" => chat_id}}}) do
    _ = send_message(chat_id, "Hello world")
    :ok
  end

  defp handle_hello(_update), do: :ok

  defp extract_chat_id(%{"message" => %{"chat" => %{"id" => chat_id}}}), do: chat_id
  defp extract_chat_id(_update), do: nil

  defp normalize_params(params) do
    Keyword.update(params, :allowed_updates, nil, &encode_allowed_updates/1)
  end

  defp encode_allowed_updates(value) when is_list(value), do: Jason.encode!(value)
  defp encode_allowed_updates(value), do: value

  defp maybe_put(params, _key, nil), do: params
  defp maybe_put(params, key, value), do: Keyword.put(params, key, value)
end
