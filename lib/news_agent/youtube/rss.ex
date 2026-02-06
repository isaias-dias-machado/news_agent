defmodule NewsAgent.YouTube.RSS do
  @moduledoc """
  Fetches and parses YouTube Atom feeds for channel entries.

  The caller provides a channel id and receives link and published timestamps
  for entries. Failures return an empty list to keep callers resilient.
  """

  @type entry :: %{link: String.t(), published: DateTime.t()}
  require Logger

  @doc """
  Fetches YouTube Atom entries for the given channel id.

  Returns a list of entries with a link and published timestamp, or an empty
  list when the feed cannot be fetched or parsed.
  """
  @spec fetch_entries(String.t()) :: [entry]
  def fetch_entries(channel_id) when is_binary(channel_id) do
    url = feed_url(channel_id)

    Logger.debug(fn -> "YouTube RSS fetch channel_id=#{channel_id} url=#{url}" end)

    url
    |> Req.get()
    |> parse_response()
  end

  defp feed_url(channel_id) do
    "https://www.youtube.com/feeds/videos.xml?channel_id=#{channel_id}"
  end

  defp parse_response({:ok, %Req.Response{status: status, body: body}})
       when status in 200..299 do
    parse_entries(body)
  end

  defp parse_response({:ok, %Req.Response{status: status} = response}) do
    Logger.debug(fn ->
      "YouTube RSS unexpected status=#{status} response=#{inspect(response)}"
    end)

    []
  end

  defp parse_response({:error, reason}) do
    Logger.debug(fn -> "YouTube RSS request error reason=#{inspect(reason)}" end)
    []
  end

  defp parse_entries(body) when is_binary(body) do
    sanitized = sanitize_xml(normalize_binary(body))

    try do
      {doc, _} =
        sanitized
        |> String.to_charlist()
        |> :xmerl_scan.string(quiet: true, validation: false, encoding: ~c"utf-8")

      entries = :xmerl_xpath.string(~c"//entry", doc)

      entries
      |> Enum.reduce([], fn entry, acc ->
        link = entry_link(entry)
        published = entry_published(entry)

        if is_binary(link) and not is_nil(published) do
          [%{link: link, published: published} | acc]
        else
          acc
        end
      end)
      |> Enum.reverse()
    catch
      :exit, reason ->
        Logger.debug(fn -> "YouTube RSS parse failed reason=#{inspect(reason)}" end)
        []
    end
  end

  defp parse_entries(_body), do: []

  defp entry_link(entry) do
    xpath_value(~c"string(link[@rel=\"alternate\"]/@href)", entry)
  end

  defp entry_published(entry) do
    entry
    |> published_text()
    |> parse_datetime()
  end

  defp published_text(entry) do
    case xpath_value(~c"string(published)", entry) do
      nil -> updated_text(entry)
      value -> value
    end
  end

  defp updated_text(entry) do
    xpath_value(~c"string(updated)", entry)
  end

  defp xpath_value(path, entry) do
    value =
      case :xmerl_xpath.string(path, entry) do
        [] -> ""
        {:xmlObj, :string, string} -> List.to_string(string)
        result when is_list(result) -> List.to_string(result)
        result -> to_string(result)
      end

    case String.trim(value) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(text) do
    case DateTime.from_iso8601(text) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end

  defp normalize_binary(xml) do
    case :unicode.characters_to_binary(xml, :utf8, :utf8) do
      binary when is_binary(binary) -> binary
      {:error, binary, _rest} -> binary
      {:incomplete, binary, _rest} -> binary
    end
  end

  defp sanitize_xml(xml) do
    for <<codepoint::utf8 <- xml>>, valid_xml_char?(codepoint) and codepoint < 128, into: "" do
      <<codepoint::utf8>>
    end
  end

  defp valid_xml_char?(codepoint) do
    codepoint == 0x9 or codepoint == 0xA or codepoint == 0xD or
      (codepoint >= 0x20 and codepoint <= 0xD7FF) or
      (codepoint >= 0xE000 and codepoint <= 0xFFFD) or
      (codepoint >= 0x10000 and codepoint <= 0x10FFFF)
  end
end
