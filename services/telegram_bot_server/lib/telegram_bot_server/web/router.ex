defmodule TelegramBotServer.Web.Router do
  @moduledoc """
  HTTP API for workspace registration and message polling.

  Contract:
  - `POST /register` registers chat ownership for a workspace.
  - `GET /queue` returns queued messages for a workspace.
  """

  use Plug.Router

  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "ok")
  end

  post "/register" do
    case conn.body_params do
      %{"workspace_id" => workspace_id, "chat_ids" => chat_ids}
      when is_binary(workspace_id) and is_list(chat_ids) ->
        case normalize_chat_ids(chat_ids) do
          {:ok, normalized} ->
            {:ok, assigned, conflicts} =
              TelegramBotServer.Queue.register(workspace_id, normalized)

            status = if conflicts == [], do: 201, else: 409
            payload = %{workspace_id: workspace_id, assigned: assigned, conflicts: conflicts}
            send_json(conn, status, payload)

          {:error, reason} ->
            send_json(conn, 400, %{error: reason})
        end

      _ ->
        send_json(conn, 400, %{error: "workspace_id and chat_ids are required"})
    end
  end

  get "/queue" do
    workspace_id = Map.get(conn.params, "workspace_id")

    case workspace_id do
      nil ->
        send_json(conn, 400, %{error: "workspace_id is required"})

      _ ->
        limit = parse_limit(conn.params)
        messages = TelegramBotServer.Queue.dequeue(workspace_id, limit)
        send_json(conn, 200, %{workspace_id: workspace_id, messages: messages})
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp normalize_chat_ids(chat_ids) do
    {valid, invalid} = Enum.split_with(chat_ids, &valid_chat_id?/1)

    case invalid do
      [] -> {:ok, Enum.map(valid, &normalize_chat_id/1)}
      _ -> {:error, "chat_ids must be integers or strings"}
    end
  end

  defp valid_chat_id?(chat_id) when is_integer(chat_id), do: true
  defp valid_chat_id?(chat_id) when is_binary(chat_id), do: true
  defp valid_chat_id?(_chat_id), do: false

  defp normalize_chat_id(chat_id) when is_integer(chat_id), do: Integer.to_string(chat_id)
  defp normalize_chat_id(chat_id) when is_binary(chat_id), do: chat_id

  defp parse_limit(params) do
    limit = Map.get(params, "limit", "")

    parsed =
      case Integer.parse(limit) do
        {value, _} -> value
        :error -> TelegramBotServer.Config.queue_default_limit()
      end

    parsed
    |> max(1)
    |> min(TelegramBotServer.Config.queue_max_limit())
  end

  defp send_json(conn, status, payload) do
    body = Jason.encode!(payload)

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, body)
  end
end
