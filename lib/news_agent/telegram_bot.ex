defmodule NewsAgent.TelegramBot do
  @moduledoc """
  Boundary for Telegram delivery and polling.

  Contract: callers enqueue and dequeue raw Telegram update maps for local
  processing, and use `get_updates/1` and `send_message/3` to interact with the
  Telegram API via a runtime-selected adapter.

  Tensions: the in-memory queue is process-local and volatile, so restarts drop
  pending updates. Adapter calls depend on external services when in real mode,
  or on in-memory state when in mock mode, so callers must handle retries,
  deduplication, and persistence outside this boundary.
  """

  use GenServer

  @type update :: map()

  @default_dequeue_limit 25

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  @doc """
  Enqueues a Telegram update for later processing.
  """
  @spec enqueue_update(update(), keyword()) :: :ok
  def enqueue_update(update, opts \\ []) do
    GenServer.call(server_name(opts), {:enqueue, update})
  end

  @doc """
  Dequeues updates in FIFO order.
  """
  @spec dequeue(pos_integer() | nil, keyword()) :: [update()]
  def dequeue(limit \\ @default_dequeue_limit, opts \\ []) do
    limit = normalize_limit(limit)
    GenServer.call(server_name(opts), {:dequeue, limit})
  end

  @doc """
  Clears all queued updates.
  """
  @spec reset(keyword()) :: :ok
  def reset(opts \\ []) do
    GenServer.call(server_name(opts), :reset)
  end

  @doc """
  Fetches updates from Telegram using the configured adapter.
  """
  @spec get_updates(keyword()) :: {:ok, [map()]} | {:error, term()}
  def get_updates(params \\ []) when is_list(params) do
    adapter().get_updates(params)
  end

  @doc """
  Sends a message to a Telegram chat using the configured adapter.
  """
  @spec send_message(String.t(), String.t(), keyword()) :: :ok | {:error, term()}
  def send_message(chat_id, text, opts \\ []) when is_binary(chat_id) and is_binary(text) do
    adapter().send_message(chat_id, text, opts)
  end

  @impl true
  def init(:ok) do
    {:ok, %{queue: :queue.new()}}
  end

  @impl true
  def handle_call({:enqueue, update}, _from, state) do
    queue = :queue.in(update, state.queue)
    {:reply, :ok, %{state | queue: queue}}
  end

  def handle_call({:dequeue, limit}, _from, state) do
    {updates, queue} = take_from_queue(state.queue, limit, [])
    {:reply, updates, %{state | queue: queue}}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{queue: :queue.new()}}
  end

  defp take_from_queue(queue, 0, acc), do: {Enum.reverse(acc), queue}

  defp take_from_queue(queue, limit, acc) do
    case :queue.out(queue) do
      {{:value, update}, queue} -> take_from_queue(queue, limit - 1, [update | acc])
      {:empty, queue} -> {Enum.reverse(acc), queue}
    end
  end

  defp normalize_limit(limit) when is_integer(limit) and limit > 0, do: limit
  defp normalize_limit(_limit), do: @default_dequeue_limit

  defp server_name(opts) do
    Keyword.get(opts, :server, __MODULE__)
  end

  defp adapter do
    case System.get_env("NEWS_AGENT_TELEGRAM_MODE", "real") do
      "mock" -> NewsAgent.TelegramBot.Adapter.Mock
      _ -> NewsAgent.TelegramBot.Adapter.Real
    end
  end
end
