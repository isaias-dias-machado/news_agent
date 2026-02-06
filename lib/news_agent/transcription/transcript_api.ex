defmodule NewsAgent.Transcription.TranscriptAPI do
  @moduledoc """
  TranscriptAPI client boundary for fetching YouTube transcripts.

  Contract: callers supply a YouTube URL or video id and receive transcript text.
  This module performs outbound HTTP calls, requires `TRANSCRIPT_API_KEY`, and
  depends on external availability and credit status.

  Tensions: network failures, rate limits, or missing transcripts surface as
  error tuples; callers must handle these failures and avoid assuming transcripts
  are always available.
  """

  @doc """
  Fetches a plain text transcript for a YouTube URL or video id.
  """
  @spec fetch_transcript(String.t(), Keyword.t()) :: {:ok, String.t()} | {:error, term()}
  def fetch_transcript(video_url, opts \\ []) when is_binary(video_url) and is_list(opts) do
    with {:ok, api_key} <- api_key(),
         {:ok, response} <- request_transcript(video_url, api_key, opts),
         {:ok, transcript} <- extract_transcript(response) do
      {:ok, transcript}
    end
  end

  defp request_transcript(video_url, api_key, opts) do
    base_url = base_url()
    url = "#{base_url}/youtube/transcript"
    params = Keyword.merge([video_url: video_url, format: "text", include_timestamp: false], opts)
    headers = [{"authorization", "Bearer #{api_key}"}]

    case Req.get(url: url, params: params, headers: headers) do
      {:ok, %Req.Response{status: 200} = response} -> {:ok, response}
      {:ok, %Req.Response{status: status, body: body}} -> {:error, {:http_error, status, body}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp extract_transcript(%Req.Response{body: %{"transcript" => transcript}})
       when is_binary(transcript) do
    {:ok, String.trim(transcript)}
  end

  defp extract_transcript(%Req.Response{body: %{"transcript" => transcript}})
       when is_list(transcript) do
    text =
      transcript
      |> Enum.map(&Map.get(&1, "text"))
      |> Enum.filter(&is_binary/1)
      |> Enum.join(" ")

    {:ok, String.trim(text)}
  end

  defp extract_transcript(%Req.Response{body: body}), do: {:error, {:unexpected_body, body}}

  defp base_url do
    System.get_env("TRANSCRIPT_API_BASE_URL", "https://transcriptapi.com/api/v2")
  end

  defp api_key do
    case System.get_env("TRANSCRIPT_API_KEY") do
      key when is_binary(key) and key != "" -> {:ok, key}
      _ -> {:error, :missing_api_key}
    end
  end
end
