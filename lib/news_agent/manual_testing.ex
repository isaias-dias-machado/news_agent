defmodule NewsAgent.ManualTesting do
  @moduledoc """
  Manual testing façade for transcript retrieval and chat interaction.

  Contract: callers provide a YouTube URL or chat input and receive the same
  result as the function under test. This module performs external HTTP requests
  or in-memory chat flows depending on the entry point.
  """

  alias NewsAgent.{Chat, YouTube}

  @doc """
  Fetches a transcript and returns the result tuple.
  """
  @spec run(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def run(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    YouTube.transcript_for_video(video_url, opts)
  end

  @doc """
  Fetches a Gemini summary and returns the result tuple.
  """
  @spec run_gemini(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def run_gemini(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    NewsAgent.YouTube.Transcription.Gemini.summarize_video(video_url, opts)
  end

  @doc """
  Runs a minimal onboarding flow and LLM response using the chat context.
  """
  @spec run_chat_flow(String.t(), Keyword.t()) :: {:ok, [map()]} | {:error, term()}
  def run_chat_flow(text, opts \\ []) when is_binary(text) and is_list(opts) do
    chat_id = Keyword.get(opts, :chat_id, 111_222_333)

    opts =
      opts
      |> Keyword.put_new(:provider, NewsAgent.Chat.LLM.Echo)
      |> Keyword.put_new(:register?, false)
      |> Keyword.put_new(:send?, false)

    with {:ok, first} <- Chat.handle_update(build_update(chat_id, "Hello"), opts),
         {:ok, linked} <- Chat.handle_update(build_update(chat_id, "OK"), opts),
         {:ok, reply} <- Chat.handle_update(build_update(chat_id, text), opts) do
      {:ok, [first, linked, reply]}
    end
  end

  defp build_update(chat_id, text) do
    %{"message" => %{"chat" => %{"id" => chat_id}, "text" => text}}
  end
end
