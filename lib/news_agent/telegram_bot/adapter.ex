defmodule NewsAgent.TelegramBot.Adapter do
  @moduledoc false

  @callback get_updates(keyword()) :: {:ok, [map()]} | {:error, term()}
  @callback send_message(String.t(), String.t(), keyword()) :: :ok | {:error, term()}
end
