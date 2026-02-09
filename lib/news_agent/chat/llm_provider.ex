defmodule NewsAgent.Chat.LLM.Provider do
  @moduledoc false

  @callback generate(String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
end
