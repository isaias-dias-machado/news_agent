defmodule NewsAgent.TelegramBot.Adapter.Mock do
  @moduledoc false

  @behaviour NewsAgent.TelegramBot.Adapter

  use GenServer

  @type update :: map()

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: server_name(opts))
  end

  @spec enqueue_update(update()) :: :ok
  def enqueue_update(update) when is_map(update) do
    :ok = ensure_started()
    GenServer.call(server_name([]), {:enqueue, update})
  end

  @impl true
  def get_updates(params \\ []) when is_list(params) do
    :ok = ensure_started()
    GenServer.call(server_name([]), {:get_updates, params})
  end

  @impl true
  def send_message(chat_id, text, opts \\ []) when is_binary(chat_id) and is_binary(text) do
    :ok = ensure_started()
    GenServer.call(server_name([]), {:send_message, chat_id, text, opts})
  end

  @spec sent_messages() :: [map()]
  def sent_messages do
    :ok = ensure_started()
    GenServer.call(server_name([]), :sent_messages)
  end

  @spec reset() :: :ok
  def reset do
    :ok = ensure_started()
    GenServer.call(server_name([]), :reset)
  end

  @impl true
  def init(:ok) do
    {:ok, %{updates: [], sent_messages: []}}
  end

  @impl true
  def handle_call({:enqueue, update}, _from, state) do
    {:reply, :ok, %{state | updates: state.updates ++ [update]}}
  end

  def handle_call({:get_updates, params}, _from, state) do
    offset = Keyword.get(params, :offset)
    updates = apply_offset(state.updates, offset)
    {:reply, {:ok, updates}, %{state | updates: []}}
  end

  def handle_call({:send_message, chat_id, text, opts}, _from, state) do
    message = %{chat_id: chat_id, text: text, opts: opts}
    {:reply, :ok, %{state | sent_messages: state.sent_messages ++ [message]}}
  end

  def handle_call(:sent_messages, _from, state) do
    {:reply, state.sent_messages, state}
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{updates: [], sent_messages: []}}
  end

  defp ensure_started do
    case Process.whereis(server_name([])) do
      nil -> start_link([]) |> start_result()
      _pid -> :ok
    end
  end

  defp start_result({:ok, _pid}), do: :ok
  defp start_result({:error, {:already_started, _pid}}), do: :ok
  defp start_result({:error, reason}), do: raise(reason)

  defp apply_offset(updates, offset) when is_integer(offset) do
    Enum.filter(updates, fn update -> update_id(update) >= offset end)
  end

  defp apply_offset(updates, _offset), do: updates

  defp update_id(update) do
    Map.get(update, "update_id") || Map.get(update, :update_id) || 0
  end

  defp server_name(opts) do
    Keyword.get(opts, :name, __MODULE__)
  end
end
