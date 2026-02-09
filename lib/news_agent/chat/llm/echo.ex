defmodule NewsAgent.Chat.LLM.Echo do
  @moduledoc false

  @behaviour NewsAgent.Chat.LLM.Provider

  @impl true
  def generate(prompt, _opts) do
    {:ok, String.trim(to_string(prompt))}
  end
end
