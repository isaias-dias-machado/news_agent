defmodule NewsAgent.YouTube.Transcription.Gemini do
  @moduledoc """
  Boundary for Gemini-backed YouTube video summaries.

  Contract: callers supply a YouTube URL and receive a summary derived from
  multimodal video content. This module performs network calls to Gemini and
  honors `GEMINI_VIDEO_MODEL` and `GEMINI_VIDEO_MIME_TYPE` at runtime.

  Tensions: external model availability and video fetches can fail or return
  empty content, so callers must handle error tuples.
  """

  alias NewsAgent.Gemini

  @doc """
  Summarizes a YouTube video using Gemini multimodal inputs.
  """
  @spec summarize_video(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def summarize_video(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    Gemini.summarize_video_url(video_url, opts)
  end
end
