defmodule TelegramBotServer.Queue do
  @moduledoc """
  In-memory routing registry and per-workspace message queues.

  Contract:
  - Chat ownership is registered per workspace.
  - Incoming updates are routed by chat id to the owning workspace queue.
  - Messages are removed from the queue when read.
  """

  use GenServer

  @type workspace_id :: String.t()
  @type chat_id :: String.t()
  @type message :: %{
          id: non_neg_integer(),
          workspace_id: workspace_id(),
          chat_id: chat_id(),
          update: map(),
          received_at: integer()
        }

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put(opts, :name, __MODULE__))
  end

  @spec register(workspace_id(), [chat_id()]) :: {:ok, [chat_id()], [map()]}
  def register(workspace_id, chat_ids) when is_binary(workspace_id) and is_list(chat_ids) do
    GenServer.call(__MODULE__, {:register, workspace_id, chat_ids})
  end

  @spec enqueue_update(map()) :: {:ok, non_neg_integer()} | {:error, term()}
  def enqueue_update(update) when is_map(update) do
    GenServer.call(__MODULE__, {:enqueue, update})
  end

  @spec dequeue(workspace_id(), pos_integer()) :: [message()]
  def dequeue(workspace_id, limit) when is_binary(workspace_id) and is_integer(limit) do
    GenServer.call(__MODULE__, {:dequeue, workspace_id, limit})
  end

  @impl true
  def init(:ok) do
    {:ok, %{next_id: 1, queues: %{}, chat_map: %{}}}
  end

  @impl true
  def handle_call({:register, workspace_id, chat_ids}, _from, state) do
    {assigned, conflicts, chat_map} = register_chat_ids(state.chat_map, workspace_id, chat_ids)
    {:reply, {:ok, assigned, conflicts}, %{state | chat_map: chat_map}}
  end

  def handle_call({:enqueue, update}, _from, state) do
    case extract_chat_id(update) do
      nil ->
        {:reply, {:error, :missing_chat_id}, state}

      chat_id ->
        chat_id = normalize_chat_id(chat_id)

        case Map.get(state.chat_map, chat_id) do
          nil ->
            {:reply, {:error, :unmapped_chat}, state}

          workspace_id ->
            message = %{
              id: state.next_id,
              workspace_id: workspace_id,
              chat_id: chat_id,
              update: update,
              received_at: System.system_time(:millisecond)
            }

            queue = Map.get(state.queues, workspace_id, :queue.new())
            queue = :queue.in(message, queue)
            queues = Map.put(state.queues, workspace_id, queue)
            {:reply, {:ok, message.id}, %{state | next_id: state.next_id + 1, queues: queues}}
        end
    end
  end

  def handle_call({:dequeue, workspace_id, limit}, _from, state) do
    queue = Map.get(state.queues, workspace_id, :queue.new())
    {messages, queue} = take_from_queue(queue, limit, [])

    queues =
      case :queue.is_empty(queue) do
        true -> Map.delete(state.queues, workspace_id)
        false -> Map.put(state.queues, workspace_id, queue)
      end

    {:reply, messages, %{state | queues: queues}}
  end

  defp register_chat_ids(chat_map, workspace_id, chat_ids) do
    Enum.reduce(chat_ids, {[], [], chat_map}, fn chat_id, {assigned, conflicts, acc} ->
      chat_id = normalize_chat_id(chat_id)

      case Map.get(acc, chat_id) do
        nil ->
          {[
             chat_id | assigned
           ], conflicts, Map.put(acc, chat_id, workspace_id)}

        ^workspace_id ->
          {[
             chat_id | assigned
           ], conflicts, acc}

        other_workspace ->
          conflict = %{chat_id: chat_id, workspace_id: other_workspace}
          {assigned, [conflict | conflicts], acc}
      end
    end)
    |> then(fn {assigned, conflicts, acc} ->
      {Enum.reverse(assigned), Enum.reverse(conflicts), acc}
    end)
  end

  defp take_from_queue(queue, 0, acc), do: {Enum.reverse(acc), queue}

  defp take_from_queue(queue, limit, acc) do
    case :queue.out(queue) do
      {{:value, message}, queue} -> take_from_queue(queue, limit - 1, [message | acc])
      {:empty, queue} -> {Enum.reverse(acc), queue}
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
end
