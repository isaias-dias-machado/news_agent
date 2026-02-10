defmodule NewsAgent.Gemini.Client do
  @moduledoc """
  HTTP client for Gemini content generation.

  Used by chat and transcription flows to call the Gemini REST API with
  explicit timeouts and structured error responses for logging.
  """

  @base_url "https://generativelanguage.googleapis.com/v1beta"
  @default_model "gemini-2.0-flash-lite"

  @spec generate(map(), Keyword.t()) :: {:ok, map()} | {:error, term()}
  def generate(payload, opts) when is_map(payload) and is_list(opts) do
    api_key = System.fetch_env!("GEMINI_API_KEY")
    model = Keyword.get(opts, :model, @default_model)
    timeout_ms = Keyword.get(opts, :timeout_ms, 60_000)

    headers = [
      {"content-type", "application/json"},
      {"x-goog-api-key", api_key}
    ]

    url = "#{@base_url}/models/#{model}:generateContent"

    req =
      Req.new(
        url: url,
        headers: headers,
        receive_timeout: timeout_ms
      )

    case Req.post(req, json: payload) do
      {:ok, %Req.Response{status: status, body: body, headers: response_headers}} ->
        if status in 200..299 do
          {:ok, body}
        else
          {:error, %{status: status, body: body, headers: response_headers}}
        end

      {:error, %Req.TransportError{reason: reason}} ->
        {:error, reason}

      {:error, error} ->
        {:error, error}
    end
  end

  @spec extract_text(map()) :: {:ok, String.t()} | {:error, term()}
  def extract_text(response) when is_map(response) do
    candidates = fetch_key(response, "candidates", :candidates)

    case candidates do
      [candidate | _] when is_map(candidate) ->
        candidate
        |> fetch_key("content", :content)
        |> extract_parts()

      _ ->
        {:error, :empty_response}
    end
  end

  defp extract_parts(%{} = content) do
    parts = fetch_key(content, "parts", :parts)

    texts =
      case parts do
        list when is_list(list) ->
          Enum.flat_map(list, fn part ->
            case fetch_key(part, "text", :text) do
              value when is_binary(value) -> [value]
              _ -> []
            end
          end)

        _ ->
          []
      end

    text = Enum.join(texts, "")

    if text == "" do
      {:error, :empty_response}
    else
      {:ok, text}
    end
  end

  defp extract_parts(_), do: {:error, :empty_response}

  defp fetch_key(map, string_key, atom_key) when is_map(map) do
    Map.get(map, string_key) || Map.get(map, atom_key)
  end
end
