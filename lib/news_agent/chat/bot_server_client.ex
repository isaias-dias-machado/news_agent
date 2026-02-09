defmodule NewsAgent.Chat.BotServerClient do
  @moduledoc false

  @spec register(String.t(), [String.t()], keyword()) :: {:ok, map()} | {:error, term()}
  def register(workspace_id, chat_ids, opts \\ [])
      when is_binary(workspace_id) and is_list(chat_ids) do
    payload = %{workspace_id: workspace_id, chat_ids: chat_ids}
    client = Req.new(base_url: base_url(opts))

    case Req.post(client, url: "/register", json: payload) do
      {:ok, %Req.Response{status: status, body: body}} when status in [201, 409] ->
        {:ok, body}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:unexpected_status, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec dequeue(String.t(), pos_integer(), keyword()) :: {:ok, [map()]} | {:error, term()}
  def dequeue(workspace_id, limit, opts \\ [])
      when is_binary(workspace_id) and is_integer(limit) do
    client = Req.new(base_url: base_url(opts))

    case Req.get(client, url: "/queue", params: %{workspace_id: workspace_id, limit: limit}) do
      {:ok, %Req.Response{status: status, body: body}} when status in 200..299 ->
        messages = Map.get(body, "messages", [])
        {:ok, messages}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:unexpected_status, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp base_url(opts) do
    case Keyword.get(opts, :bot_server_url) || System.get_env("TELEGRAM_BOT_SERVER_URL") do
      value when is_binary(value) and value != "" -> value
      _ -> "http://127.0.0.1:8090"
    end
  end
end
