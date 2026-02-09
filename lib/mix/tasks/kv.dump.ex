defmodule Mix.Tasks.Kv.Dump do
  use Mix.Task

  alias NewsAgent.KVStore

  @shortdoc "Dumps KV tables from data/kv"

  @moduledoc """
  Dumps entries from DETS-backed KV tables.

  Use --table to target a single table and --limit to control inspect output size.
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, _rest, invalid} =
      OptionParser.parse(args, switches: [table: :string, limit: :integer])

    if invalid != [] do
      Mix.raise("Invalid options: #{inspect(invalid)}")
    end

    limit = normalize_limit(opts[:limit])

    case opts[:table] do
      nil -> dump_all_tables(limit)
      table -> dump_single_table(table, limit)
    end
  end

  defp dump_all_tables(limit) do
    tables = list_tables()

    if tables == [] do
      Mix.shell().info("No kv tables found in data/kv.")
    else
      last_index = length(tables) - 1

      tables
      |> Enum.with_index()
      |> Enum.each(fn {table, index} ->
        dump_table(table, limit)

        if index < last_index do
          IO.puts("")
        end
      end)
    end
  end

  defp dump_single_table(table, limit) do
    dump_table(normalize_table_arg(table), limit)
  end

  defp dump_table(table_name, limit) do
    IO.puts("table: #{table_name}")

    case KVStore.open(table_name) do
      {:ok, table} ->
        result = KVStore.all(table)
        _ = KVStore.close(table)

        case result do
          {:ok, entries} ->
            entries
            |> apply_limit(limit)
            |> build_tree()
            |> print_tree()

          {:error, reason} ->
            Mix.raise("Failed to read table #{table_name}: #{inspect(reason)}")
        end

      {:error, reason} ->
        Mix.raise("Failed to open table #{table_name}: #{inspect(reason)}")
    end
  end

  defp list_tables do
    [File.cwd!(), "data", "kv", "*.dets"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".dets"))
    |> Enum.sort()
  end

  defp normalize_table_arg(table) do
    table
    |> Path.basename()
    |> String.replace_suffix(".dets", "")
  end

  defp normalize_limit(nil), do: :infinity
  defp normalize_limit(limit) when is_integer(limit) and limit > 0, do: limit
  defp normalize_limit(limit), do: Mix.raise("Invalid --limit value: #{inspect(limit)}")

  defp apply_limit(entries, :infinity), do: entries
  defp apply_limit(entries, limit), do: Enum.take(entries, limit)

  defp build_tree(entries) do
    Enum.reduce(entries, %{children: %{}, value: nil}, fn {key, value}, tree ->
      insert_tree(tree, key_segments(key), value)
    end)
  end

  defp insert_tree(node, [segment], value) do
    child = Map.get(node.children, segment, %{children: %{}, value: nil})
    updated_child = %{child | value: value}

    %{node | children: Map.put(node.children, segment, updated_child)}
  end

  defp insert_tree(node, [segment | rest], value) do
    child = Map.get(node.children, segment, %{children: %{}, value: nil})
    updated_child = insert_tree(child, rest, value)

    %{node | children: Map.put(node.children, segment, updated_child)}
  end

  defp key_segments(key) when is_binary(key) do
    segments = String.split(key, "/", trim: true)
    if segments == [], do: [key], else: segments
  end

  defp key_segments(key), do: [inspect(key)]

  defp print_tree(%{children: children}) when map_size(children) == 0 do
    IO.puts("(empty)")
  end

  defp print_tree(%{children: children}) do
    children
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0))
    |> print_tree_nodes("")
  end

  defp print_tree_nodes(nodes, prefix) do
    last_index = length(nodes) - 1

    nodes
    |> Enum.with_index()
    |> Enum.each(fn {entry, index} ->
      print_tree_node(entry, prefix, index == last_index)
    end)
  end

  defp print_tree_node({segment, node}, prefix, last?) do
    connector = if last?, do: "`-- ", else: "|-- "
    IO.puts(prefix <> connector <> format_node_line(segment, node))

    if map_size(node.children) > 0 do
      child_prefix = prefix <> if(last?, do: "    ", else: "|   ")

      node.children
      |> Map.to_list()
      |> Enum.sort_by(&elem(&1, 0))
      |> print_tree_nodes(child_prefix)
    end
  end

  defp format_node_line(segment, %{value: nil}), do: segment

  defp format_node_line(segment, %{value: value}) do
    segment <> " = " <> inspect(value, pretty: true)
  end
end
