defmodule NewsAgent.ManualTesting do
  @moduledoc """
  Manual testing façade for transcript retrieval.

  Contract: callers provide a YouTube URL or video id and receive a filesystem
  result containing the transcript. This module performs external HTTP requests
  and returns the same result as the function under test.
  """

  alias NewsAgent.YouTube

  @doc """
  Fetches a transcript and returns the result tuple.
  """
  @spec run(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def run(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    YouTube.transcript_for_video(video_url, opts)
  end
end
