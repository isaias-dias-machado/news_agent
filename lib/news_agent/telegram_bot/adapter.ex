defmodule NewsAgent.TelegramBot.Adapter do
  @moduledoc false

  alias NewsAgent.TelegramBot.Update

  @callback get_updates(keyword()) :: {:ok, [Update.t()]} | {:error, term()}
  @callback send_message(String.t(), String.t(), keyword()) :: :ok | {:error, term()}
end
