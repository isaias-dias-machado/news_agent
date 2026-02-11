defmodule NewsAgent.UrlStrategyRouter.FeedStrategy do
  @moduledoc """
  Classifies RSS or Atom feeds using minimal HTTP inspection.
  """

  @behaviour NewsAgent.UrlStrategyRouter.Strategy

  @feed_content_types [
    "application/rss+xml",
    "application/atom+xml",
    "application/xml",
    "text/xml"
  ]

  @impl true
  def match?(%URI{}, _opts), do: true

  @impl true
  def classify(%URI{} = uri, opts) do
    url = Keyword.get(opts, :normalized_url, URI.to_string(uri))

    case fetch_head(url, opts) do
      {:ok, headers} ->
        if feed_content_type?(headers) do
          confirm_feed(url, opts)
        else
          {:error, :not_supported}
        end

      {:error, _reason} ->
        confirm_feed(url, opts)
    end
  end

  defp confirm_feed(url, opts) do
    case fetch_get(url, opts) do
      {:ok, headers, body, final_url} ->
        if feed_content_type?(headers) and feed_root?(body) do
          {:ok,
           %{
             type: :feed,
             source_url: final_url,
             canonical_url: final_url,
             confidence: 0.8
           }}
        else
          {:error, :not_supported}
        end

      {:error, _reason} ->
        {:error, :not_supported}
    end
  end

  defp fetch_head(url, opts) do
    request_opts = request_opts(opts)

    case Req.request([method: :head, url: url] ++ request_opts) do
      {:ok, %{status: status, headers: headers}} when status in 200..299 ->
        {:ok, headers}

      {:ok, _response} ->
        {:error, :not_supported}

      {:error, _reason} ->
        {:error, :not_supported}
    end
  end

  defp fetch_get(url, opts) do
    request_opts = request_opts(opts)
    headers = request_opts[:headers] || []
    max_body = normalize_max_body(opts)
    range_header = {"range", "bytes=0-#{max_body - 1}"}
    request_opts = Keyword.put(request_opts, :headers, [range_header | headers])

    case Req.request([method: :get, url: url] ++ request_opts) do
      {:ok, %{status: status, headers: headers, body: body} = response} when status in 200..299 ->
        final_url = Map.get(response, :url, url)
        {:ok, headers, truncate_body(body, max_body), normalize_final_url(final_url, url)}

      {:ok, _response} ->
        {:error, :not_supported}

      {:error, _reason} ->
        {:error, :not_supported}
    end
  end

  defp truncate_body(body, max_body) when is_binary(body) and is_integer(max_body) do
    if byte_size(body) > max_body do
      binary_part(body, 0, max_body)
    else
      body
    end
  end

  defp truncate_body(body, _max_body), do: body

  defp normalize_max_body(opts) do
    case Keyword.get(opts, :max_body, 65_536) do
      value when is_integer(value) and value > 0 -> value
      _ -> 65_536
    end
  end

  defp normalize_final_url(final_url, _fallback) when is_binary(final_url), do: final_url

  defp normalize_final_url(%URI{} = final_url, _fallback), do: URI.to_string(final_url)

  defp normalize_final_url(_final_url, fallback), do: fallback

  defp request_opts(opts) do
    timeout = Keyword.get(opts, :timeout, 4_000)
    max_redirects = Keyword.get(opts, :max_redirects, 3)

    [
      receive_timeout: timeout,
      connect_options: [timeout: timeout],
      max_retries: 0,
      redirect: [max_redirects: max_redirects],
      headers: [
        {"accept", "application/rss+xml, application/atom+xml, application/xml, text/xml"},
        {"user-agent", "NewsAgentUrlStrategyRouter/1.0"}
      ]
    ]
  end

  defp feed_content_type?(headers) do
    case header_value(headers, "content-type") do
      nil ->
        false

      value ->
        value
        |> String.downcase()
        |> String.split(";", parts: 2)
        |> hd()
        |> then(&(&1 in @feed_content_types))
    end
  end

  defp header_value(headers, key) do
    headers
    |> Enum.find_value(fn {header_key, value} ->
      if String.downcase(to_string(header_key)) == key do
        normalize_header_value(value)
      else
        nil
      end
    end)
  end

  defp normalize_header_value(value) when is_binary(value), do: value
  defp normalize_header_value([value | _]) when is_binary(value), do: value

  defp normalize_header_value([value | _]), do: to_string(value)
  defp normalize_header_value(value), do: to_string(value)

  defp feed_root?(body) when is_binary(body) do
    trimmed = String.trim_leading(body)

    Regex.match?(~r/^<\?xml[^>]*>\s*<\s*(rss|feed)(\s|>)/i, trimmed) or
      Regex.match?(~r/^<\s*(rss|feed)(\s|>)/i, trimmed)
  end

  defp feed_root?(_body), do: false
end
