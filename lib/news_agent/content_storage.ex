defmodule NewsAgent.ContentStorage do
  @moduledoc """
  Boundary for per-user, per-source content persistence on disk.

  Contract: callers provide a user id, slug, and content URL to store or fetch
  content records. Writes are atomic and overwrite the existing file for the
  same source, while reads validate the stored JSON schema and return structured
  data or an error when files are missing or malformed.

  Tensions: storage depends on filesystem durability and correct caller-provided
  identifiers. Invalid slugs, URLs, or corrupted JSON files result in failures
  that callers must handle explicitly.
  """

  alias NewsAgent.UrlNormalizer

  @type record :: %{
          content_url: String.t(),
          normalized_url: String.t(),
          author: String.t(),
          content: String.t(),
          fetched_at: String.t()
        }

  @doc """
  Stores content for a user/source pair with a fresh fetch timestamp.
  """
  @spec store(String.t() | pos_integer(), String.t(), String.t(), String.t(), String.t()) ::
          :ok | {:error, term()}
  def store(user_id, slug, content_url, author, content) do
    with {:ok, user_id} <- normalize_user_id(user_id),
         {:ok, slug} <- normalize_slug(slug),
         {:ok, normalized_url} <- UrlNormalizer.normalize(content_url, allow_private: true),
         {:ok, record} <- build_record(content_url, normalized_url, author, content),
         :ok <- ensure_dir(user_id) do
      json_path = path_for(user_id, slug, content_url)
      tmp_path = tmp_path(json_path)
      json = Jason.encode!(record)
      write_atomic(tmp_path, json_path, json)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Reads the stored content for a user/source pair.
  """
  @spec read(String.t() | pos_integer(), String.t(), String.t()) ::
          {:ok, record()} | :error | {:error, term()}
  def read(user_id, slug, content_url) do
    with {:ok, user_id} <- normalize_user_id(user_id),
         {:ok, slug} <- normalize_slug(slug),
         {:ok, normalized_url} <- UrlNormalizer.normalize(content_url, allow_private: true) do
      json_path = path_for(user_id, slug, content_url)

      case File.read(json_path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, data} -> validate_record(data, content_url, normalized_url)
            {:error, _reason} -> {:error, :invalid_content}
          end

        {:error, :enoent} ->
          :error

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Lists stored content file paths for a user.
  """
  @spec list_paths(String.t() | pos_integer()) :: {:ok, [String.t()]} | {:error, term()}
  def list_paths(user_id) do
    with {:ok, user_id} <- normalize_user_id(user_id) do
      dir = dir_for(user_id)

      case File.ls(dir) do
        {:ok, entries} ->
          entries
          |> Enum.filter(&(Path.extname(&1) == ".json"))
          |> Enum.map(&Path.join(dir, &1))
          |> then(&{:ok, &1})

        {:error, :enoent} ->
          {:ok, []}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_record(content_url, normalized_url, author, content)
       when is_binary(content_url) and is_binary(normalized_url) and is_binary(author) and
              is_binary(content) and content_url != "" do
    {:ok,
     %{
       content_url: content_url,
       normalized_url: normalized_url,
       author: author,
       content: content,
       fetched_at: DateTime.utc_now() |> DateTime.to_iso8601()
     }}
  end

  defp build_record(_content_url, _normalized_url, _author, _content),
    do: {:error, :invalid_content}

  defp validate_record(%{} = data, content_url, normalized_url) do
    with {:ok, stored_content_url} <- fetch_string(data, "content_url"),
         {:ok, stored_normalized_url} <- fetch_string(data, "normalized_url"),
         {:ok, author} <- fetch_string(data, "author"),
         {:ok, content} <- fetch_string(data, "content"),
         {:ok, fetched_at} <- fetch_string(data, "fetched_at"),
         true <- stored_content_url == content_url,
         true <- stored_normalized_url == normalized_url,
         true <- valid_fetched_at?(fetched_at) do
      {:ok,
       %{
         content_url: stored_content_url,
         normalized_url: stored_normalized_url,
         author: author,
         content: content,
         fetched_at: fetched_at
       }}
    else
      _ -> {:error, :invalid_content}
    end
  end

  defp validate_record(_data, _content_url, _normalized_url), do: {:error, :invalid_content}

  defp fetch_string(map, key) do
    case Map.get(map, key) do
      value when is_binary(value) -> {:ok, value}
      _ -> {:error, :invalid_content}
    end
  end

  defp valid_fetched_at?(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, dt, 0} -> DateTime.to_iso8601(dt) == value
      _ -> false
    end
  end

  defp valid_fetched_at?(_value), do: false

  defp normalize_user_id(user_id) when is_integer(user_id) and user_id > 0,
    do: {:ok, Integer.to_string(user_id)}

  defp normalize_user_id(user_id) when is_binary(user_id) and user_id != "", do: {:ok, user_id}
  defp normalize_user_id(_user_id), do: {:error, :invalid_user_id}

  defp normalize_slug(slug) when is_binary(slug) and slug != "" do
    if String.contains?(slug, "--") do
      {:error, :invalid_slug}
    else
      {:ok, slug}
    end
  end

  defp normalize_slug(_slug), do: {:error, :invalid_slug}

  defp ensure_dir(user_id) do
    case File.mkdir_p(dir_for(user_id)) do
      :ok -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp write_atomic(tmp_path, json_path, json) do
    case :file.open(tmp_path, [:write, :binary]) do
      {:ok, fd} ->
        write_result =
          try do
            with :ok <- :file.write(fd, json),
                 :ok <- :file.sync(fd) do
              :ok
            end
          after
            _ = :file.close(fd)
          end

        case write_result do
          :ok ->
            case File.rename(tmp_path, json_path) do
              :ok -> :ok
              {:error, reason} -> {:error, reason}
            end

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp path_for(user_id, slug, content_url) do
    Path.join([dir_for(user_id), "#{slug}--#{Base.encode32(content_url)}.json"])
  end

  defp tmp_path(json_path), do: json_path <> ".tmp"

  defp dir_for(user_id) do
    Path.join(["data", "users", user_id, "sources"])
  end
end
