defmodule NewsAgent.KVStoreTest do
  use ExUnit.Case, async: false

  alias NewsAgent.KVStore

  test "opens and closes a table" do
    table_name = unique_table_name()

    {:ok, table} = KVStore.open(table_name)

    on_exit(fn ->
      _ = KVStore.close(table)
      remove_dets_files(table_name)
    end)

    assert table == {KVStore, table_name}
    assert :ok = KVStore.close(table)
  end

  test "gets, puts, and deletes values" do
    {_table_name, table} = open_table()

    assert :ok = KVStore.put(table, "alpha", "bravo")
    assert {:ok, "bravo"} = KVStore.get(table, "alpha")
    assert :ok = KVStore.delete(table, "alpha")
    assert {:error, :not_found} = KVStore.get(table, "alpha")
  end

  test "normalizes atom and string keys" do
    {_table_name, table} = open_table()

    assert :ok = KVStore.put(table, :first_key, 11)
    assert {:ok, 11} = KVStore.get(table, "first_key")

    assert :ok = KVStore.put(table, "second_key", 22)
    assert {:ok, 22} = KVStore.get(table, :second_key)

    assert {:error, :invalid_key} = KVStore.get(table, 123)
  end

  test "updates existing values" do
    {_table_name, table} = open_table()

    assert :ok = KVStore.put(table, "counter", 1)
    assert {:ok, 2} = KVStore.update(table, "counter", &(&1 + 1), 0)
    assert {:ok, 2} = KVStore.get(table, "counter")
  end

  test "updates missing values using defaults" do
    {_table_name, table} = open_table()

    assert {:ok, "seeded"} = KVStore.update(table, "missing", &(&1 <> "ed"), "seed")
    assert {:ok, "seeded"} = KVStore.get(table, "missing")
  end

  test "returns all entries with normalized keys" do
    {_table_name, table} = open_table()

    assert :ok = KVStore.put(table, :one, 1)
    assert :ok = KVStore.put(table, "two", 2)

    assert {:ok, entries} = KVStore.all(table)

    entries_map = Map.new(entries)

    assert entries_map["one"] == 1
    assert entries_map["two"] == 2
  end

  defp open_table do
    table_name = unique_table_name()
    {:ok, table} = KVStore.open(table_name)

    on_exit(fn ->
      _ = KVStore.close(table)
      remove_dets_files(table_name)
    end)

    {table_name, table}
  end

  defp unique_table_name do
    "kv_store_test_#{System.unique_integer([:positive])}"
  end

  defp dets_path(table_name) do
    Path.join(["data", "kv", "#{table_name}.dets"])
  end

  defp remove_dets_files(table_name) do
    path = dets_path(table_name)

    _ = File.rm(path)
    _ = File.rm(path <> ".dets")
  end
end
