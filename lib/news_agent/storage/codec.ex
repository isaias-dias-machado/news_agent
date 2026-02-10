defmodule NewsAgent.Storage.Codec do
  @moduledoc false

  @type op ::
          {:set, String.t(), term(), integer()}
          | {:del, String.t(), integer()}

  def encode_op({:set, key, value, ts}) do
    %{
      "v" => 1,
      "op" => "set",
      "key" => key,
      "value" => value,
      "ts" => ts
    }
    |> Jason.encode!()
    |> Kernel.<>("\n")
  end

  def encode_op({:del, key, ts}) do
    %{
      "v" => 1,
      "op" => "del",
      "key" => key,
      "ts" => ts
    }
    |> Jason.encode!()
    |> Kernel.<>("\n")
  end

  def decode_line!(line, line_number) do
    payload =
      line
      |> String.trim_trailing("\n")
      |> String.trim_trailing("\r")

    data =
      case Jason.decode(payload) do
        {:ok, decoded} ->
          decoded

        {:error, error} ->
          raise "log corruption at line #{line_number}: #{Exception.message(error)}"
      end

    unless is_map(data) do
      raise "log corruption at line #{line_number}: expected JSON object"
    end

    validate_schema!(data, line_number)
  end

  defp validate_schema!(
         %{"v" => 1, "op" => "set", "key" => key, "value" => value, "ts" => ts} = data,
         line
       ) do
    ensure_only_keys!(data, ["v", "op", "key", "value", "ts"], line)
    ensure_key!(key, line)
    ensure_ts!(ts, line)
    {:set, key, value, ts}
  end

  defp validate_schema!(%{"v" => 1, "op" => "del", "key" => key, "ts" => ts} = data, line) do
    ensure_only_keys!(data, ["v", "op", "key", "ts"], line)
    ensure_key!(key, line)
    ensure_ts!(ts, line)
    {:del, key, ts}
  end

  defp validate_schema!(%{"v" => version}, line) when version != 1 do
    raise "log corruption at line #{line}: invalid version #{inspect(version)}"
  end

  defp validate_schema!(%{"op" => op}, line) when op not in ["set", "del"] do
    raise "log corruption at line #{line}: invalid op #{inspect(op)}"
  end

  defp validate_schema!(_data, line) do
    raise "log corruption at line #{line}: invalid schema"
  end

  defp ensure_only_keys!(data, allowed, line) do
    keys = Map.keys(data)

    case keys -- allowed do
      [] ->
        :ok

      unexpected ->
        raise "log corruption at line #{line}: unexpected keys #{inspect(unexpected)}"
    end
  end

  defp ensure_key!(key, line) do
    unless is_binary(key) do
      raise "log corruption at line #{line}: key must be a string"
    end
  end

  defp ensure_ts!(ts, line) do
    unless is_integer(ts) do
      raise "log corruption at line #{line}: ts must be an integer"
    end
  end
end
