defmodule NewsAgent.TelegramBotTest do
  use ExUnit.Case

  alias NewsAgent.TelegramBot
  alias NewsAgent.TelegramBot.Adapter.Mock

  setup do
    server_name = :"bot_server_test_#{System.unique_integer([:positive])}"
    start_supervised!({TelegramBot, name: server_name})
    {:ok, server: server_name}
  end

  test "enqueues and dequeues messages in FIFO order", %{server: server} do
    update_one = %{"update_id" => 1, "message" => %{"chat" => %{"id" => 123}, "text" => "hi"}}
    update_two = %{"update_id" => 2, "message" => %{"chat" => %{"id" => 123}, "text" => "yo"}}

    :ok = TelegramBot.enqueue_update(update_one, server: server)
    :ok = TelegramBot.enqueue_update(update_two, server: server)

    [first, second] = TelegramBot.dequeue(2, server: server)

    assert first["update_id"] == 1
    assert second["update_id"] == 2
  end

  test "dequeues with default limit", %{server: server} do
    update_one = %{"update_id" => 3, "message" => %{"chat" => %{"id" => 999}, "text" => "hey"}}
    update_two = %{"update_id" => 4, "message" => %{"chat" => %{"id" => 999}, "text" => "hola"}}

    :ok = TelegramBot.enqueue_update(update_one, server: server)
    :ok = TelegramBot.enqueue_update(update_two, server: server)

    messages = TelegramBot.dequeue(nil, server: server)

    assert Enum.map(messages, & &1["update_id"]) == [3, 4]
  end

  test "mock adapter enqueues and returns updates" do
    start_supervised!(Mock)
    :ok = Mock.reset()

    update = %{"update_id" => 10, "message" => %{"text" => "hello"}}
    :ok = Mock.enqueue_update(update)

    assert {:ok, [^update]} = Mock.get_updates([])
    assert {:ok, []} = Mock.get_updates([])
  end

  test "mock adapter records sent messages" do
    start_supervised!(Mock)
    :ok = Mock.reset()

    :ok = Mock.send_message("123", "hi", locale: "en")

    assert [%{chat_id: "123", text: "hi", opts: [locale: "en"]}] = Mock.sent_messages()
  end

  test "mock adapter reset clears state" do
    start_supervised!(Mock)
    :ok = Mock.enqueue_update(%{"update_id" => 22})
    :ok = Mock.send_message("456", "ok")
    :ok = Mock.reset()

    assert {:ok, []} = Mock.get_updates([])
    assert [] = Mock.sent_messages()
  end
end
