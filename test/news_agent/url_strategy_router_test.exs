defmodule NewsAgent.UrlStrategyRouterTest do
  use ExUnit.Case, async: false

  alias NewsAgent.UrlStrategyRouter

  test "classifies youtube URLs without HTTP" do
    url = "https://www.youtube.com/watch?v=abc123"

    assert {:ok, result} = UrlStrategyRouter.classify(url)
    assert result.type == :youtube
    assert result.canonical_url == url
    assert result.source_url == url
  end

  test "classifies feed URLs when content-type and root match" do
    port =
      start_server(fn _method, _path ->
        {200, [{"content-type", "application/rss+xml"}], "<rss><channel></channel></rss>"}
      end)

    url = "http://127.0.0.1:#{port}/feed"

    assert {:ok, %{type: :feed}} = UrlStrategyRouter.classify(url, allow_private: true)
  end

  test "returns not_supported for non-feed content" do
    port =
      start_server(fn _method, _path ->
        {200, [{"content-type", "text/html"}], "<html><body>nope</body></html>"}
      end)

    url = "http://127.0.0.1:#{port}/page"

    assert {:error, :not_supported} = UrlStrategyRouter.classify(url, allow_private: true)
  end

  test "returns blocked_host for localhost" do
    assert {:error, :blocked_host} =
             UrlStrategyRouter.classify("http://localhost:4000/feed")
  end

  test "returns invalid_url for unsupported schemes" do
    assert {:error, :invalid_url} = UrlStrategyRouter.classify("ftp://example.com/feed")
  end

  defp start_server(responder) do
    {:ok, socket} = :gen_tcp.listen(0, [:binary, packet: :raw, active: false, reuseaddr: true])
    {:ok, {_, port}} = :inet.sockname(socket)

    start_supervised!(%{
      id: make_ref(),
      start: {Task, :start_link, [fn -> accept_loop(socket, responder) end]}
    })

    on_exit(fn -> :gen_tcp.close(socket) end)

    port
  end

  defp accept_loop(socket, responder) do
    case :gen_tcp.accept(socket) do
      {:ok, client} ->
        _ = handle_client(client, responder)
        :gen_tcp.close(client)
        accept_loop(socket, responder)

      {:error, :closed} ->
        :ok
    end
  end

  defp handle_client(client, responder) do
    case :gen_tcp.recv(client, 0, 2_000) do
      {:ok, data} ->
        [request_line | _] = String.split(data, "\r\n", parts: 2)
        [method, path | _] = String.split(request_line, " ")
        {status, headers, body} = responder.(method, path)

        body_to_send =
          if method == "HEAD" do
            ""
          else
            body
          end

        response = build_response(status, headers, body_to_send)
        :gen_tcp.send(client, response)

      _ ->
        :ok
    end
  end

  defp build_response(status, headers, body) do
    reason = response_reason(status)

    headers =
      if Enum.any?(headers, fn {key, _value} -> String.downcase(key) == "content-length" end) do
        headers
      else
        [{"content-length", Integer.to_string(byte_size(body))} | headers]
      end

    header_lines = Enum.map(headers, fn {key, value} -> "#{key}: #{value}" end)

    [
      "HTTP/1.1 #{status} #{reason}",
      Enum.join(header_lines, "\r\n"),
      "",
      body
    ]
    |> Enum.join("\r\n")
  end

  defp response_reason(200), do: "OK"
  defp response_reason(404), do: "Not Found"
  defp response_reason(500), do: "Server Error"
  defp response_reason(_status), do: "OK"
end
