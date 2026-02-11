defmodule NewsAgent.ContentStorageTest do
  use ExUnit.Case, async: false

  alias NewsAgent.ContentStorage
  alias NewsAgent.Sources

  setup do
    user_id = "content-storage-#{System.unique_integer([:positive])}"
    dir = Path.join(["data", "users", user_id])

    on_exit(fn -> File.rm_rf(dir) end)

    {:ok, user_id: user_id}
  end

  test "stores and reads content records", %{user_id: user_id} do
    slug = "example"
    content_url = "https://example.com/article"

    assert :ok = ContentStorage.store(user_id, slug, content_url, "Author", "Body")
    assert {:ok, record} = ContentStorage.read(user_id, slug, content_url)
    assert record.content_url == content_url
    assert {:ok, normalized_url} = Sources.normalize_url(content_url)
    assert record.normalized_url == normalized_url
    assert record.author == "Author"
    assert record.content == "Body"
    assert {:ok, _dt, 0} = DateTime.from_iso8601(record.fetched_at)
  end

  test "returns :error for missing records", %{user_id: user_id} do
    assert :error = ContentStorage.read(user_id, "missing", "https://example.com/missing")
  end

  test "lists stored json paths for a user", %{user_id: user_id} do
    slug = "list"
    content_url = "https://example.com/list"
    encoded = Base.encode32(content_url)
    dir = Path.join(["data", "users", user_id, "sources"])
    json_path = Path.join(dir, "#{slug}--#{encoded}.json")
    tmp_path = json_path <> ".tmp"

    assert {:ok, []} = ContentStorage.list_paths(user_id)
    assert :ok = File.mkdir_p(dir)
    assert :ok = File.write(json_path, "{}")
    assert :ok = File.write(tmp_path, "{}")

    assert {:ok, [path]} = ContentStorage.list_paths(user_id)
    assert path == json_path
  end

  test "rejects invalid slugs", %{user_id: user_id} do
    assert {:error, :invalid_slug} =
             ContentStorage.store(user_id, "bad--slug", "https://example.com/a", "A", "B")
  end

  test "rejects malformed JSON files", %{user_id: user_id} do
    slug = "broken"
    content_url = "https://example.com/bad"
    encoded = Base.encode32(content_url)
    path = Path.join(["data", "users", user_id, "sources", "#{slug}--#{encoded}.json"])
    :ok = File.mkdir_p(Path.dirname(path))
    :ok = File.write(path, "not json")

    assert {:error, :invalid_content} = ContentStorage.read(user_id, slug, content_url)
  end
end
