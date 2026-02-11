defmodule NewsAgent.UrlStrategyRouter.YouTubeStrategy do
  @moduledoc """
  Classifies YouTube URLs without network calls.
  """

  import Kernel, except: [match?: 2]

  @behaviour NewsAgent.UrlStrategyRouter.Strategy

  @impl true
  def match?(%URI{host: host}, _opts) when is_binary(host) do
    host == "youtu.be" or host == "youtube.com" or String.ends_with?(host, ".youtube.com")
  end

  def match?(_uri, _opts), do: false

  @impl true
  def classify(%URI{} = uri, opts) do
    normalized_url = Keyword.get(opts, :normalized_url, URI.to_string(uri))

    if match?(uri, opts) do
      {:ok,
       %{
         type: :youtube,
         source_url: normalized_url,
         canonical_url: normalized_url,
         confidence: 0.9
       }}
    else
      {:error, :not_supported}
    end
  end
end
