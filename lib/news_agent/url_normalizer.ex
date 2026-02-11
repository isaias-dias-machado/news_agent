defmodule NewsAgent.UrlNormalizer do
  @moduledoc """
  Provides safe URL normalization with optional private host blocking.

  Normalization lowercases scheme/host, strips fragments and default ports, and
  returns an error when the URL is invalid, blocked, or exceeds length limits.
  """

  @type error :: :invalid_url | :blocked_host | :too_long

  @doc """
  Normalizes a URL string for routing and storage use.
  """
  @spec normalize(String.t(), keyword()) :: {:ok, String.t()} | {:error, error()}
  def normalize(url, opts \\ [])

  def normalize(url, opts) when is_binary(url) do
    max_length = normalize_max_length(opts)
    allow_private = Keyword.get(opts, :allow_private, false)
    trimmed = String.trim(url)

    case URI.parse(trimmed) do
      %URI{scheme: scheme, host: host} = uri when is_binary(scheme) and is_binary(host) ->
        scheme = String.downcase(scheme)
        host = String.downcase(host)

        if scheme in ["http", "https"] do
          if allow_private or not blocked_host?(host) do
            normalized_uri = %URI{
              uri
              | scheme: scheme,
                host: host,
                port: normalize_port(scheme, uri.port),
                fragment: nil
            }

            normalized_url = URI.to_string(normalized_uri)

            if String.length(normalized_url) <= max_length do
              {:ok, normalized_url}
            else
              {:error, :too_long}
            end
          else
            {:error, :blocked_host}
          end
        else
          {:error, :invalid_url}
        end

      _ ->
        {:error, :invalid_url}
    end
  end

  def normalize(_url, _opts), do: {:error, :invalid_url}

  defp normalize_max_length(opts) do
    case Keyword.get(opts, :max_length, 2048) do
      value when is_integer(value) and value > 0 -> value
      _ -> 2048
    end
  end

  defp normalize_port("http", 80), do: nil
  defp normalize_port("https", 443), do: nil
  defp normalize_port(_scheme, port), do: port

  defp blocked_host?("localhost"), do: true

  defp blocked_host?(host) when is_binary(host) do
    case :inet.parse_address(to_charlist(host)) do
      {:ok, address} -> private_address?(address)
      _ -> false
    end
  end

  defp blocked_host?(_host), do: false

  defp private_address?({127, _, _, _}), do: true
  defp private_address?({10, _, _, _}), do: true
  defp private_address?({169, 254, _, _}), do: true
  defp private_address?({172, second, _, _}) when second >= 16 and second <= 31, do: true
  defp private_address?({192, 168, _, _}), do: true

  defp private_address?({0, 0, 0, 0, 0, 0, 0, 1}), do: true

  defp private_address?({first, _, _, _, _, _, _, _}) when first >= 0xFC00 and first <= 0xFDFF,
    do: true

  defp private_address?({first, _, _, _, _, _, _, _}) when first >= 0xFE80 and first <= 0xFEBF,
    do: true

  defp private_address?(_address), do: false
end
