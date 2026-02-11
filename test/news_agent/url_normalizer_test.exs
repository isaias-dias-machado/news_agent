defmodule NewsAgent.UrlNormalizerTest do
  use ExUnit.Case, async: true

  alias NewsAgent.UrlNormalizer

  test "normalizes scheme, host, fragment, and default port" do
    url = "HTTPS://Example.COM:443/Path?Q=1#fragment"

    assert {:ok, "https://example.com/Path?Q=1"} = UrlNormalizer.normalize(url)
  end

  test "rejects invalid schemes" do
    assert {:error, :invalid_url} = UrlNormalizer.normalize("ftp://example.com/feed")
  end

  test "blocks private hosts by default" do
    assert {:error, :blocked_host} = UrlNormalizer.normalize("http://localhost:4000/feed")
  end

  test "allows private hosts when configured" do
    assert {:ok, "http://localhost:4000/feed"} =
             UrlNormalizer.normalize("http://localhost:4000/feed", allow_private: true)
  end

  test "rejects URLs that exceed max length" do
    assert {:error, :too_long} =
             UrlNormalizer.normalize("https://example.com/long", max_length: 10)
  end
end
