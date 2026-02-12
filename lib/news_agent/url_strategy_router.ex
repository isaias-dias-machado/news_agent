defmodule NewsAgent.UrlStrategyRouter do
  @moduledoc "This module processes URLs to figure out if it is supported."

  def route(url) when is_binary(url) do
    with url_normalized <- NewsAgent.UrlNormalizer.normalize(url) do
      cond do
        youtube_channel?(url_normalized) -> NewsAgent.YouTube
        true -> :url_not_supported
      end
    end
  end

  defp youtube_channel?(url_normalized) do
    String.contains?(url_normalized, "youtu") and
      String.contains?(url_normalized, "@")
  end
end
