defmodule NewsAgent.Scheduler.JobRunner do
  @moduledoc """
  Defines the contract for executing scheduler jobs.

  Contract: implementors receive a user id and UTC date string and return
  `:ok` on success or `{:error, term}` on failure. Jobs must not retry; the
  scheduler controls retry cadence.

  Tensions: job execution may involve external systems and side effects,
  so failures must be surfaced without retries to preserve scheduler semantics.
  """

  @callback run(term(), String.t()) :: :ok | {:error, term()}

  @doc """
  Default no-op job runner used when no custom runner is configured.
  """
  @spec run(term(), String.t()) :: :ok
  def run(_user_id, _today), do: :ok
end
