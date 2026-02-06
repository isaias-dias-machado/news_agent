defmodule NewsAgent.ManualTesting do
  @moduledoc """
  Manual testing façade for transcript-based video summaries.

  Contract: callers provide a YouTube URL or video id and receive a filesystem
  path containing the generated summary. This module performs external HTTP
  requests, LLM calls, and filesystem writes, and raises on any failure to
  surface issues during manual testing.
  """

  import Bitwise

  alias NewsAgent.Gemini
  alias NewsAgent.Transcription.TranscriptAPI

  @doc """
  Fetches a transcript, summarizes it, and writes the summary to disk.
  """
  @spec run(String.t(), Keyword.t()) :: String.t()
  def run(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    transcript = fetch_transcript!(video_url, opts)
    summary = summarize!(transcript, opts)
    write_summary!(summary)
  end

  defp fetch_transcript!(video_url, opts) do
    case TranscriptAPI.fetch_transcript(video_url, opts) do
      {:ok, transcript} when byte_size(transcript) > 0 -> transcript
      {:ok, _} -> raise "TranscriptAPI returned empty transcript"
      {:error, reason} -> raise "TranscriptAPI failed: #{inspect(reason)}"
    end
  end

  defp summarize!(transcript, opts) do
    case Gemini.summarize_text(transcript, opts) do
      {:ok, summary} when byte_size(summary) > 0 -> summary
      {:ok, _} -> raise "Gemini returned empty summary"
      {:error, reason} -> raise "Gemini summarization failed: #{inspect(reason)}"
    end
  end

  defp write_summary!(summary) do
    date = Date.utc_today() |> Date.to_iso8601()
    uuid = uuid4()
    dir = Path.join(["data", "users", "isaias", date])
    path = Path.join(dir, "#{uuid}.txt")

    File.mkdir_p!(dir)
    File.write!(path, summary)

    path
  end

  defp uuid4 do
    bytes = :crypto.strong_rand_bytes(16)
    list = :binary.bin_to_list(bytes)

    list =
      list
      |> List.update_at(6, fn byte -> (byte &&& 0x0F) ||| 0x40 end)
      |> List.update_at(8, fn byte -> (byte &&& 0x3F) ||| 0x80 end)

    hex = Base.encode16(:binary.list_to_bin(list), case: :lower)

    <<p1::binary-size(8), p2::binary-size(4), p3::binary-size(4), p4::binary-size(4),
      p5::binary-size(12)>> = hex

    "#{p1}-#{p2}-#{p3}-#{p4}-#{p5}"
  end
end
