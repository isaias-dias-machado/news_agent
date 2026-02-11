defmodule NewsAgent.Chat.Poller do
  @moduledoc false

  use GenServer

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = %{interval_ms: poll_interval(opts)}
    send(self(), :poll)
    {:ok, state}
  end

  @impl true
  def handle_info(:poll, state) do
    start = System.monotonic_time()
    reductions_before = reductions_total()
    memory_before = :erlang.memory(:total)

    result = NewsAgent.Chat.poll()

    duration_ms =
      System.monotonic_time()
      |> Kernel.-(start)
      |> System.convert_time_unit(:native, :millisecond)

    reductions_after = reductions_total()
    memory_after = :erlang.memory(:total)

    measurements = %{
      duration_ms: duration_ms,
      handled: handled_count(result),
      reductions: reductions_after - reductions_before,
      memory_bytes: memory_after - memory_before
    }

    :telemetry.execute([:news_agent, :chat, :poll], measurements, %{})

    interval = next_interval(result, state.interval_ms)
    _ = Process.send_after(self(), :poll, interval)
    {:noreply, state}
  end

  defp poll_interval(opts) do
    value = Keyword.get(opts, :interval_ms) || System.get_env("NEWS_AGENT_CHAT_POLL_INTERVAL_MS")

    case value do
      int when is_integer(int) and int > 0 -> int
      str when is_binary(str) -> parse_interval(str)
      _ -> 500
    end
  end

  defp next_interval(_result, default), do: default

  defp parse_interval(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> 500
    end
  end

  defp reductions_total do
    :erlang.statistics(:reductions)
    |> elem(0)
  end

  defp handled_count({:ok, count}) when is_integer(count), do: count
  defp handled_count(_result), do: 0
end
