defmodule NewsAgent.UrlStrategyRouter do
  @moduledoc """
  Boundary for classifying a URL into a retrieval strategy.

  Contract: callers provide a URL string and optional routing options. The router
  normalizes and validates the URL, checks YouTube first, then attempts feed
  classification, and returns a strategy map or a normalized error.

  Tensions: routing must be fast and safe, rejecting invalid or blocked hosts
  while performing only minimal HTTP calls for feed detection. Callers must
  handle transient network failures and explicit unsupported results.
  """

  alias NewsAgent.UrlNormalizer
  alias NewsAgent.UrlStrategyRouter.FeedStrategy
  alias NewsAgent.UrlStrategyRouter.YouTubeStrategy
  require Logger

  @strategies [YouTubeStrategy, FeedStrategy]

  @type error_reason :: :not_supported | :invalid_url | :blocked_host | :too_long

  @doc """
  Classifies a URL into a routing strategy.
  """
  @spec classify(String.t(), keyword()) ::
          {:ok, NewsAgent.UrlStrategyRouter.Strategy.strategy_map()}
          | {:error, error_reason()}
  def classify(url, opts \\ []) do
    start_time = System.monotonic_time()

    {result, logged_url} =
      if is_binary(url) do
        normalized_opts = normalize_opts(opts)

        case UrlNormalizer.normalize(url, normalized_opts) do
          {:ok, normalized_url} ->
            uri = URI.parse(normalized_url)
            result = route(uri, Keyword.put(normalized_opts, :normalized_url, normalized_url))
            {result, url}

          {:error, reason} ->
            {{:error, reason}, url}
        end
      else
        {{:error, :invalid_url}, inspect(url)}
      end

    duration_ms =
      System.monotonic_time()
      |> Kernel.-(start_time)
      |> System.convert_time_unit(:native, :millisecond)

    Logger.debug(fn ->
      "url_strategy_router route finished url=#{logged_url} result=#{format_result(result)} duration_ms=#{duration_ms}"
    end)

    result
  end

  defp route(%URI{} = uri, opts) do
    Enum.reduce_while(@strategies, {:error, :not_supported}, fn strategy, _acc ->
      if strategy.match?(uri, opts) do
        case strategy.classify(uri, opts) do
          {:ok, _strategy_map} = ok -> {:halt, ok}
          {:error, :not_supported} -> {:cont, {:error, :not_supported}}
        end
      else
        {:cont, {:error, :not_supported}}
      end
    end)
  end

  defp normalize_opts(opts) do
    opts
    |> Keyword.put_new(:max_length, 2048)
    |> Keyword.put_new(:allow_private, false)
    |> Keyword.put_new(:timeout, 4_000)
    |> Keyword.put_new(:max_redirects, 3)
    |> Keyword.put_new(:max_body, 65_536)
  end

  defp format_result({:ok, %{type: type}}), do: "ok:" <> to_string(type)
  defp format_result({:error, reason}), do: "error:" <> to_string(reason)
  defp format_result(_result), do: "error:unknown"
end
