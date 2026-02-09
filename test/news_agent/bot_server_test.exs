defmodule NewsAgent.BotServerTest do
  use ExUnit.Case

  alias NewsAgent.BotServer

  setup do
    server_name = :"bot_server_test_#{System.unique_integer([:positive])}"
    start_supervised!({BotServer, name: server_name})
    {:ok, server: server_name}
  end

  test "enqueues and dequeues messages in FIFO order", %{server: server} do
    update_one = %{"update_id" => 1, "message" => %{"chat" => %{"id" => 123}, "text" => "hi"}}
    update_two = %{"update_id" => 2, "message" => %{"chat" => %{"id" => 123}, "text" => "yo"}}

    :ok = BotServer.enqueue(update_one, server: server)
    :ok = BotServer.enqueue(update_two, server: server)

    [first, second] = BotServer.dequeue(2, server: server)

    assert first["update_id"] == 1
    assert second["update_id"] == 2
  end

  test "dequeues with default limit", %{server: server} do
    update_one = %{"update_id" => 3, "message" => %{"chat" => %{"id" => 999}, "text" => "hey"}}
    update_two = %{"update_id" => 4, "message" => %{"chat" => %{"id" => 999}, "text" => "hola"}}

    :ok = BotServer.enqueue(update_one, server: server)
    :ok = BotServer.enqueue(update_two, server: server)

    messages = BotServer.dequeue(nil, server: server)

    assert Enum.map(messages, & &1["update_id"]) == [3, 4]
  end
end
