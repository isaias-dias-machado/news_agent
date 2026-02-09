defmodule NewsAgent.ManualTesting do
  @moduledoc """
  Manual testing façade for transcript retrieval and Gemini summaries.

  Contract: callers provide a YouTube URL or video id and receive a result
  containing transcript text or a summary depending on the configured provider.
  This module performs external HTTP requests and returns the same result as the
  function under test.
  """

  alias NewsAgent.YouTube

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
end
