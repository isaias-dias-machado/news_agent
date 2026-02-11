defmodule NewsAgent.UrlStrategyRouter.Strategy do
  @moduledoc """
  Defines the URL strategy behavior contract for routing classification.
  """

  @type strategy_map :: %{
          required(:type) => :youtube | :feed,
          required(:source_url) => String.t(),
          required(:canonical_url) => String.t(),
          required(:confidence) => float()
        }

  @callback match?(URI.t(), keyword()) :: boolean()
  @callback classify(URI.t(), keyword()) :: {:ok, strategy_map()} | {:error, :not_supported}
end
