defmodule NewsAgent.Chat do
  @moduledoc """
  Boundary for chat onboarding and LLM interaction.

  Contract: callers provide Telegram updates or invoke polling and receive
  responses that are delivered to the originating chat. This module pulls from
  the in-memory bot queue, calls the Telegram API for responses, keeps
  onboarding state in memory, and routes user input to the configured LLM
  provider.

  Tensions: message delivery depends on external services and network
  availability; callers should expect transient failures and ensure the bot
  server queues are polled frequently enough to avoid backlog growth.
  """

  alias NewsAgent.Chat.Session
  alias NewsAgent.TelegramBot
  alias NewsAgent.TelegramBot.Update

  @doc """
  Polls the bot server queues and handles updates.
  """
  @spec poll(keyword()) :: {:ok, non_neg_integer()} | {:error, term()}
  def poll(opts \\ []) do
    limit = Keyword.get(opts, :limit, 25)
    updates = TelegramBot.dequeue(limit)
    results = Enum.map(updates, &handle_update(&1, opts))
    handled = Enum.count(results, &match?({:ok, _}, &1))
    {:ok, handled}
  end

  @doc """
  Handles a Telegram update map and replies to the chat.
  """
  @spec handle_update(Update.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def handle_update(%Update{} = update, opts \\ []) do
    case extract_chat_id(update) do
      nil ->
        {:error, :missing_chat_id}

      chat_id ->
        message = %{"chat_id" => chat_id, "update" => update}
        handle_message(message, opts)
    end
  end

  @doc """
  Resets the in-memory chat context for the given chat id.
  """
  @spec reset_context(String.t() | integer(), keyword()) :: :ok | {:error, term()}
  def reset_context(chat_id, opts \\ []) do
    chat_id = normalize_chat_id(chat_id)
    Session.reset_context(chat_id, opts)
  end

  defp handle_message(message, opts) do
    chat_id = normalize_chat_id(Map.get(message, "chat_id"))
    update = Map.get(message, "update", %{})

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
        TelegramBot.send_message(chat_id, reply, opts)

      true ->
        :ok
    end
  end

  defp extract_chat_id(%Update{message: message}) do
    get_in(message || %{}, ["chat", "id"])
  end

  defp normalize_chat_id(chat_id) when is_integer(chat_id), do: Integer.to_string(chat_id)
  defp normalize_chat_id(chat_id) when is_binary(chat_id), do: chat_id
  defp normalize_chat_id(chat_id), do: to_string(chat_id)
end
