defmodule NewsAgent.MixProject do
  use Mix.Project

  def project do
    [
      app: :news_agent,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xmerl],
      mod: {NewsAgent.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gemini_ex, "~> 0.9.1"},
      {:jason, "~> 1.4"},
      {:req, "~> 0.5"}
    ]
  end
end
