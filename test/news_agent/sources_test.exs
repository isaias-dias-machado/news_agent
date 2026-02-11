defmodule NewsAgent.SourcesTest do
  use ExUnit.Case, async: false

  alias NewsAgent.Sources
  alias NewsAgent.Storage

  setup do
    unique = System.unique_integer([:positive])
    dir = "data/source_strategies_test_#{unique}"
    sources_name = :"sources_test_#{unique}"
    storage_name = :"sources_storage_#{unique}"

    start_supervised!({Sources, [name: sources_name, dir: dir, storage_name: storage_name]})

    on_exit(fn ->
      _ = File.rm_rf(dir)
    end)

    %{sources_name: sources_name, storage_name: storage_name}
  end

  test "normalize_url lowercases host and strips fragment" do
    url = "https://Example.com/Path?Q=1#fragment"

    assert {:ok, "https://example.com/Path?Q=1"} = Sources.normalize_url(url)
  end

  test "persist_strategy and fetch_strategy round trip", %{sources_name: sources_name} do
    canonical_url = "https://Example.com/news?x=1#frag"
    strategy = %{type: :rss, source_url: canonical_url}
    last_verified_at = ~U[2026-02-09 00:00:00Z]

    assert :ok =
             Sources.persist_strategy(sources_name, canonical_url, %{
               strategy: strategy,
               confidence: 0.82,
               last_verified_at: last_verified_at
             })

    assert {:ok, record} = Sources.fetch_strategy(sources_name, canonical_url)
    assert record.canonical_url == canonical_url
    assert record.normalized_url == "https://example.com/news?x=1"
    assert record.strategy == strategy
    assert record.confidence == 0.82
    assert record.last_verified_at == last_verified_at
  end

  test "strategy_for validates persisted record", %{sources_name: sources_name} do
    canonical_url = "https://example.com/feed"
    last_verified_at = ~U[2026-02-09 00:00:00Z]

    assert :ok =
             Sources.persist_strategy(sources_name, canonical_url, %{
               strategy: %{type: "rss", source_url: canonical_url},
               confidence: 0.95,
               last_verified_at: last_verified_at
             })

    assert {:ok, record} = Sources.strategy_for(sources_name, canonical_url)
    assert record.canonical_url == canonical_url
    assert record.strategy.type == "rss"
  end

  test "persist_strategy rejects invalid strategy input", %{sources_name: sources_name} do
    canonical_url = "https://example.com/feed"

    assert {:error, :invalid_strategy} =
             Sources.persist_strategy(sources_name, canonical_url, %{
               confidence: 0.5,
               last_verified_at: ~U[2026-02-09 00:00:00Z]
             })
  end

  test "strategy_for returns error for invalid stored record", %{
    sources_name: sources_name,
    storage_name: storage_name
  } do
    canonical_url = "https://example.com/invalid"

    {:ok, normalized_url} = Sources.normalize_url(canonical_url)

    :ok =
      Storage.put(storage_name, normalized_url, %{
        strategy: %{type: :rss, source_url: canonical_url}
      })

    assert {:error, :invalid_strategy} = Sources.strategy_for(sources_name, canonical_url)
  end
end
