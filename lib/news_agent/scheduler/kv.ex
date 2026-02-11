defmodule NewsAgent.Scheduler.KV do
  @moduledoc """
  Boundary for durable scheduler state per user.

  Contract: callers read and persist per-user scheduler records, including
  daily finalization status and delivery time. The boundary ensures required
  fields are present and emits telemetry for finalization outcomes.

  Tensions: updates must respect daily cutoff boundaries and rely on durable
  storage, so callers must handle persistence errors without assuming retries.
  """

  alias NewsAgent.Chat
  alias NewsAgent.UserConfigs

  require Logger

  @type due_time :: {hour :: 0..23, minute :: 0..59}

  @type record :: %{
          required(:user_id) => term(),
          required(:due_time) => due_time(),
          required(:last_date) => String.t() | nil,
          required(:status) => :success | :cutoff_reached | nil,
          required(:last_run_at) => String.t() | nil,
          required(:schema_version) => 1
        }

  @schema_version 1

  @doc """
  Fetches a user record.
  """
  @spec fetch(term()) :: {:ok, record()} | :error | {:error, term()}
  def fetch(user_id) do
    case UserConfigs.get(user_id) do
      {:ok, record} -> normalize_record(record)
      :error -> :error
    end
  end

  @doc """
  Lists all stored user records.
  """
  @spec list_users() :: {:ok, [record()]} | {:error, term()}
  def list_users do
    users =
      UserConfigs.list_for_scheduler()
      |> Enum.flat_map(fn record ->
        case normalize_record(record) do
          {:ok, normalized} -> [normalized]
          :error -> []
          {:error, _reason} -> []
        end
      end)

    {:ok, users}
  end

  @doc """
  Persists a scheduler record for a user.
  """
  @spec put_user(record()) :: :ok | {:error, term()}
  def put_user(%{user_id: user_id} = record) do
    case normalize_record(record) do
      {:ok, normalized} ->
        case UserConfigs.update_scheduler(user_id, %{
               due_time: normalized.due_time,
               last_date: normalized.last_date,
               status: normalized.status,
               last_run_at: normalized.last_run_at
             }) do
          {:ok, _record} -> :ok
          {:error, reason} -> {:error, reason}
        end

      :error ->
        {:error, :invalid_record}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def put_user(_record), do: {:error, :invalid_record}

  @doc """
  Finalizes success for a user on the given day.
  """
  @spec finalize_success(term(), String.t(), DateTime.t()) :: :ok | :late_success | {:error, term()}
  def finalize_success(user_id, today, now) do
    case UserConfigs.get(user_id) do
      {:ok, record} ->
        case normalize_record(record) do
          {:ok, normalized} ->
            if normalized.last_date == today do
              :late_success
            else
              case UserConfigs.update_scheduler(user_id, %{
                     last_date: today,
                     status: :success,
                     last_run_at: DateTime.to_iso8601(now)
                   }) do
                {:ok, _updated} ->
                  emit_finalize(%{normalized | status: :success}, today)
                  :ok

                {:error, reason} ->
                  Logger.debug("scheduler kv finalize success failed", reason: reason)
                  {:error, reason}
              end
            end

          :error ->
            {:error, :invalid_record}

          {:error, reason} ->
            {:error, reason}
        end

      :error ->
        {:error, :not_found}
    end
  end

  @doc """
  Finalizes cutoff for a user on the given day.
  """
  @spec finalize_cutoff(term(), String.t()) :: :ok | {:error, term()}
  def finalize_cutoff(user_id, today) do
    case UserConfigs.get(user_id) do
      {:ok, record} ->
        case normalize_record(record) do
          {:ok, normalized} ->
            if normalized.last_date == today do
              :ok
            else
              case UserConfigs.update_scheduler(user_id, %{
                     last_date: today,
                     status: :cutoff_reached
                   }) do
                {:ok, _updated} ->
                  emit_finalize(%{normalized | status: :cutoff_reached}, today)
                  maybe_reset_chat(record)
                  :ok

                {:error, reason} ->
                  Logger.debug("scheduler kv finalize cutoff failed", reason: reason)
                  {:error, reason}
              end
            end

          :error ->
            {:error, :invalid_record}

          {:error, reason} ->
            {:error, reason}
        end

      :error ->
        {:error, :not_found}
    end
  end

  defp normalize_record(%{user_id: user_id, due_time: due_time} = record)
       when not is_nil(user_id) do
    with :ok <- validate_due_time(due_time) do
      {:ok,
       %{
         user_id: user_id,
         due_time: due_time,
         last_date: Map.get(record, :last_date),
         status: Map.get(record, :status),
         last_run_at: Map.get(record, :last_run_at),
         schema_version: @schema_version
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_record(%{id: user_id, due_time: due_time} = record)
       when not is_nil(user_id) do
    with :ok <- validate_due_time(due_time) do
      {:ok,
       %{
         user_id: user_id,
         due_time: due_time,
         last_date: Map.get(record, :last_date),
         status: Map.get(record, :status),
         last_run_at: Map.get(record, :last_run_at),
         schema_version: @schema_version
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_record(_record), do: :error

  defp validate_due_time({hour, minute})
       when is_integer(hour) and is_integer(minute) and hour in 0..23 and minute in 0..59 do
    :ok
  end

  defp validate_due_time(_due_time), do: {:error, :invalid_due_time}

  defp emit_finalize(record, today) do
    due_bucket = due_bucket(record.due_time)

    :telemetry.execute(
      [:sched, :finalize],
      %{},
      %{status: record.status, due_bucket: due_bucket, today: today}
    )
  end

  defp due_bucket({hour, minute}) do
    hour * 60 + minute
  end

  defp maybe_reset_chat(%{chat_id: chat_id}) when is_binary(chat_id) and chat_id != "" do
    case Chat.reset_context(chat_id, []) do
      :ok -> :ok
      {:error, reason} -> Logger.debug("scheduler chat reset failed", reason: reason)
    end
  end

  defp maybe_reset_chat(_record), do: :ok
end
