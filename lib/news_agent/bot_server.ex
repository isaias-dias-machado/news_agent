defmodule NewsAgent.BotServer do
  @moduledoc """
  Boundary for an in-memory Telegram update queue.

  Contract: callers enqueue raw Telegram update maps and dequeue them in FIFO
  order. Updates are stored only in memory and are removed once dequeued.

  Tensions: the queue is process-local and volatile, so restarts drop pending
  updates and there is no routing, validation, or persistence. Callers must
  decide how to filter, retry, and persist updates outside this boundary.
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
  @spec enqueue(update(), keyword()) :: :ok
  def enqueue(update, opts \\ []) do
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
end
