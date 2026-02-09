defmodule NewsAgent.Chat do
  @moduledoc """
  Boundary for chat onboarding and LLM interaction.

  Contract: callers provide Telegram updates or invoke polling and receive
  responses that are delivered to the originating chat. This module performs
  HTTP requests to the bot server and Telegram API, keeps onboarding state in
  memory, and routes user input to the configured LLM provider.

  Tensions: message delivery depends on external services and network
  availability; callers should expect transient failures and ensure the bot
  server queues are polled frequently enough to avoid backlog growth.
  """

  alias NewsAgent.Chat.{BotServerClient, Session, TelegramClient}

  @unmapped_workspace_id "unmapped"

  @doc """
  Polls the bot server queues and handles updates.
  """
  @spec poll(keyword()) :: {:ok, non_neg_integer()} | {:error, term()}
  def poll(opts \\ []) do
    workspace_id = workspace_id(opts)
    limit = Keyword.get(opts, :limit, 25)
    opts = Keyword.put(opts, :workspace_id, workspace_id)

    with {:ok, unmapped} <- BotServerClient.dequeue(@unmapped_workspace_id, limit, opts),
         {:ok, mapped} <- BotServerClient.dequeue(workspace_id, limit, opts) do
      messages = unmapped ++ mapped
      results = Enum.map(messages, &handle_message(&1, opts))
      handled = Enum.count(results, &match?({:ok, _}, &1))
      {:ok, handled}
    end
  end

  @doc """
  Handles a Telegram update map and replies to the chat.
  """
  @spec handle_update(map(), keyword()) :: {:ok, map()} | {:error, term()}
  def handle_update(update, opts \\ []) when is_map(update) do
    case extract_chat_id(update) do
      nil ->
        {:error, :missing_chat_id}

      chat_id ->
        message = %{"chat_id" => chat_id, "update" => update}
        handle_message(message, opts)
    end
  end

  defp handle_message(message, opts) do
    chat_id = normalize_chat_id(Map.get(message, "chat_id"))
    update = Map.get(message, "update", %{})
    opts = Keyword.put(opts, :workspace_id, workspace_id(opts))

    case Session.handle_update(chat_id, update, opts) do
      {:ok, {reply, status}} ->
        with :ok <- maybe_send(chat_id, reply, opts) do
          {:ok, %{chat_id: chat_id, status: status, reply: reply}}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_send(chat_id, reply, opts) do
    cond do
      reply in [nil, ""] ->
        :ok

      Keyword.get(opts, :send?, true) ->
        TelegramClient.send_message(chat_id, reply, opts)

      true ->
        :ok
    end
  end

  defp extract_chat_id(update) do
    get_in(update, ["message", "chat", "id"]) ||
      get_in(update, ["edited_message", "chat", "id"]) ||
      get_in(update, ["channel_post", "chat", "id"])
  end

  defp normalize_chat_id(chat_id) when is_integer(chat_id), do: Integer.to_string(chat_id)
  defp normalize_chat_id(chat_id) when is_binary(chat_id), do: chat_id
  defp normalize_chat_id(chat_id), do: to_string(chat_id)

  defp workspace_id(opts) do
    case Keyword.get(opts, :workspace_id) || System.get_env("NEWS_AGENT_WORKSPACE_ID") do
      value when is_binary(value) and value != "" -> value
      _ -> "default"
    end
  end
end
