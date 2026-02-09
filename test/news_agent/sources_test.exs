defmodule NewsAgent.SourcesTest do
  use ExUnit.Case, async: false

  alias NewsAgent.KVStore
  alias NewsAgent.Sources

  setup do
    dets_path = Path.join(["data", "kv", "source_strategies.dets"])

    _ = File.rm(dets_path)

    on_exit(fn ->
      _ = File.rm(dets_path)
    end)

    :ok
  end

  test "normalize_url lowercases host and strips fragment" do
    url = "https://Example.com/Path?Q=1#fragment"

    assert {:ok, "https://example.com/Path?Q=1"} = Sources.normalize_url(url)
  end

  test "persist_strategy and fetch_strategy round trip" do
    canonical_url = "https://Example.com/news?x=1#frag"
    strategy = %{type: :rss, source_url: canonical_url}
    last_verified_at = ~U[2026-02-09 00:00:00Z]

    assert :ok =
             Sources.persist_strategy(canonical_url, %{
               strategy: strategy,
               confidence: 0.82,
               last_verified_at: last_verified_at
             })

    assert {:ok, record} = Sources.fetch_strategy(canonical_url)
    assert record.canonical_url == canonical_url
    assert record.normalized_url == "https://example.com/news?x=1"
    assert record.strategy == strategy
    assert record.confidence == 0.82
    assert record.last_verified_at == last_verified_at
  end

  test "strategy_for validates persisted record" do
    canonical_url = "https://example.com/feed"
    last_verified_at = ~U[2026-02-09 00:00:00Z]

    assert :ok =
             Sources.persist_strategy(canonical_url, %{
               strategy: %{type: "rss", source_url: canonical_url},
               confidence: 0.95,
               last_verified_at: last_verified_at
             })

    assert {:ok, record} = Sources.strategy_for(canonical_url)
    assert record.canonical_url == canonical_url
    assert record.strategy.type == "rss"
  end

  test "persist_strategy rejects invalid strategy input" do
    canonical_url = "https://example.com/feed"

    assert {:error, :invalid_strategy} =
             Sources.persist_strategy(canonical_url, %{
               confidence: 0.5,
               last_verified_at: ~U[2026-02-09 00:00:00Z]
             })
  end

  test "strategy_for returns error for invalid stored record" do
    canonical_url = "https://example.com/invalid"

    {:ok, normalized_url} = Sources.normalize_url(canonical_url)
    {:ok, table} = KVStore.open(:source_strategies)

    :ok =
      KVStore.put(table, normalized_url, %{
        strategy: %{type: :rss, source_url: canonical_url}
      })

    :ok = KVStore.close(table)

    assert {:error, :invalid_strategy} = Sources.strategy_for(canonical_url)
  end
end
