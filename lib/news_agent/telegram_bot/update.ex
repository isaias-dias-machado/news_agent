defmodule NewsAgent.TelegramBot.Update do
  @moduledoc """
  Normalized Telegram update representation for chat ingestion.
  """

  @type chat_id :: integer()

  @typedoc """
  Telegram chat payload fields (string-keyed in the raw update map).
  """
  @type chat :: %{
          first_name: String.t(),
          id: chat_id(),
          last_name: String.t(),
          type: String.t()
        }

  @typedoc """
  Telegram sender payload fields (string-keyed in the raw update map).
  """
  @type sender :: %{
          first_name: String.t(),
          id: integer(),
          is_bot: boolean(),
          language_code: String.t(),
          last_name: String.t()
        }

  @typedoc """
  Telegram message payload fields (string-keyed in the raw update map).
  """
  @type message :: %{
          chat: chat(),
          date: integer(),
          from: sender(),
          message_id: integer(),
          text: String.t()
        }

  @type t :: %__MODULE__{
          update_id: non_neg_integer(),
          message: message() | nil
        }

  @derive Jason.Encoder
  defstruct [:update_id, :message]

  @spec from_map(map()) :: t()
  def from_map(update) when is_map(update) do
    %__MODULE__{
      update_id: normalize_update_id(update),
      message: normalize_message(update)
    }
  end

  defp normalize_message(update) do
    Map.get(update, "message") ||
      Map.get(update, :message) ||
      Map.get(update, "edited_message") ||
      Map.get(update, :edited_message) ||
      Map.get(update, "channel_post") ||
      Map.get(update, :channel_post)
  end

  defp normalize_update_id(update) do
    value = Map.get(update, "update_id") || Map.get(update, :update_id) || 0

    case value do
      int when is_integer(int) and int >= 0 ->
        int

      str when is_binary(str) ->
        case Integer.parse(str) do
          {parsed, _} when parsed >= 0 -> parsed
          _ -> 0
        end

      _ ->
        0
    end
  end
end
