# Implementation SPEC — Daily Per-User Scheduler (v1.1 with Observability)

## Objective

For each user, attempt a daily job within a **window** that starts **60 minutes before** delivery time and ends at delivery time (UTC cutoff). By cutoff, persist a durable status for the day. Single-node monolith. Allowed deps: OTP stdlib + `Jason` + `Req`.

---

## 1) Frozen Correctness Invariants

### I1 — At most one successful run per user per UTC day

A user may not record `:success` twice for the same `today` (UTC).

### I2 — Survive crashes without silent skips

After restart, any user not finalized for `today` must remain eligible under window rules.

### I3 — Global concurrency is bounded

Total concurrent job executions ≤ `max_concurrency`.

### I4 — Tick is lightweight

Tick must never block on job execution; it only plans/enqueues/finalizes cutoff.

### I5 — Prefer delivery over dedupe

Duplicate attempts are acceptable in rare crash windows; silent skips are not.
Durable state is written only on finalization (success/cutoff), never on claim.

### I6 — Exactly one finalization per user per day by cutoff

By a user’s cutoff time (their delivery `due_time`), system must persist for `today`:

* `:success` if any attempt succeeded within the window
* else `:cutoff_reached`

---

## 2) Out of Scope (v1)

Time zones/DST, multi-node coordination, durable queues, fairness guarantees, per-user rate limits, infinite retries, catch-up for missed past days. All time is UTC.

---

## 3) Data Model (KV per user, durable)

Required:

```elixir
due_time: {hour :: 0..23, minute :: 0..59}        # UTC delivery time (cutoff)
last_date: "YYYY-MM-DD" | nil                     # UTC date of last finalization
status: :success | :cutoff_reached | nil          # meaningful when last_date is set
```

Optional debug:

```elixir
last_run_at: utc_timestamp | nil
```

**Meaning:** user is finalized today iff `last_date == today`.

---

## 4) Scheduling Window & Retry Policy

Parameters:

* `window_minutes = 60` (fixed for v1)
* `retry_delay_minutes = 10` (fixed for v1)
* `start_time = due_time - window_minutes`
* `cutoff_time = due_time`

Eligibility:

* Attempt only when `start_time <= now < cutoff_time`
* Retry allowed while eligible, throttled by `retry_delay`

Cutoff finalization:

* At any tick where `now >= cutoff_time`, if not finalized today → finalize `:cutoff_reached`.

---

## 5) Planner Semantics (Tick)

### Tick interval

Every `tick_ms` (default 60_000).

### Planner responsibilities (no job execution)

Compute `now`, `today`. Iterate all users.

For each user:

1. If `last_date == today`: skip.
2. Else if `now >= cutoff_time`: emit cutoff finalize request.
3. Else if `start_time <= now < cutoff_time`: emit enqueue request.
4. Else: skip (too early).

Planner emits messages; never blocks on executor.

---

## 6) In-Memory Queue & Dedupe

### Structures

No ordering requirement.

Implementation options:

* GenServer state with `:queue` and `MapSet`
* or ETS table(s)

Minimum required:

* `queued_or_running :: MapSet(user_id)`
* `next_attempt_at :: map {user_id, today} -> unix_ms` (ephemeral throttle)
* `queue :: :queue` (FIFO not required; can push/pop any order)

### Enqueue rule

On `{:enqueue, user_id, today, now}`:

* If `user_id in queued_or_running` → ignore.
* Else if `now < next_attempt_at[{user_id,today}]` (if present) → ignore.
* Else:

  * add to `queued_or_running`
  * push into `queue`
  * set `next_attempt_at[{user_id,today}] = now + retry_delay`

User is removed from `queued_or_running` after task completes (success/failure).

---

## 7) Executor Semantics

Executor drains `queue` continuously and runs jobs using:

`Task.Supervisor.async_stream_nolink/3` with:

* `max_concurrency = K`
* `ordered: false`
* `timeout: job_timeout_ms`

Result handling:

* Always remove `queued_or_running[user_id]`.
* On success: attempt to finalize KV as `:success` for `today`.
* On failure: log debug details; do not finalize (eligible until cutoff).

---

## 8) Finalization Rules (Success vs Cutoff)

### Success finalization (durable)

When job returns success:

* Persist KV: `last_date=today`, `status=:success`, `last_run_at=now`

**Must be conditional** to respect cutoff boundary:

* If KV already has `last_date=today` (cutoff finalized) → do not overwrite; log “late success”.
* Otherwise write success.

### Cutoff finalization (durable)

When planner detects `now >= cutoff_time` and `last_date != today`:

* Persist KV: `last_date=today`, `status=:cutoff_reached`
* Reset chat context for the user and ensure the next interaction starts with a
  fresh LLM context via `NewsAgent.Chat`

Cutoff is a hard boundary.

---

## 9) Job Contract

`JobRunner.run(user_id, today) :: :ok | {:error, term}`

No retries inside the job; retries are scheduler-level only.

---

## 10) Supervisor Topology

```
Application
 ├─ Task.Supervisor
 ├─ Scheduler.KV
 ├─ Scheduler.Queue
 ├─ Scheduler.Tick
 ├─ Scheduler.Executor
 └─ Scheduler.Obs.SLOWatcher   (v1 observability only)
```

---

# 11) Observability Requirements (Telemetry v1 + Debug Logs)

## 11.1 Goals (what we care about)

Primary scalability concerns:

* Tick scan cost (O(users))
* Queue pressure (backlog growth)
* Concurrency saturation
* Job latency (throughput limiter)
* Window outcomes (cutoff misses)

Everything else is debug logging “on the spot”.

---

## 11.2 Telemetry v1 (required events)

### E1 — Tick cost

Event: `[:sched, :tick, :stop]` (use `:telemetry.span/3`)
Measurements:

* `duration_ms`
  Metadata:
* `users_scanned`
* `eligible_in_window`
* `enqueued`
* `cutoff_finalized`

### E2 — Queue depth (gauge)

Event: `[:sched, :queue, :depth]`
Measurements:

* `depth`
  Metadata:
* `today`

Emit at least once per tick and/or after enqueue/drain operations.

### E3 — Executor in-flight (gauge)

Event: `[:sched, :executor, :in_flight]`
Measurements:

* `in_flight`
  Metadata:
* `max_concurrency`

Emit on changes and/or once per tick.

### E4 — Job latency + result

Event: `[:sched, :job, :stop]` (wrap each run in a span)
Measurements:

* `duration_ms`
  Metadata:
* `result` (`:ok | :error | :timeout`)
* `error_class` (`:req | :llm | :parse | :unknown`) on failure only

### E5 — Daily finalization outcome

Event: `[:sched, :finalize]`
Measurements: none required
Metadata:

* `status` (`:success | :cutoff_reached`)
* `due_bucket` (minute-of-day integer 0..1439 derived from `due_time`)
* `today`

---

## 11.3 Debug logging policy (required)

Use `Logger.debug` for per-user/attempt details (not telemetry):

* enqueue ignored because dedupe/throttle (include reason)
* job error details (term, truncated payload sizes if needed)
* “late success” (success after cutoff finalized)
* KV update failures

Keep `Logger.info/warn` reserved for:

* SLO breaches
* unexpected crashes/exit reasons
* persistent KV failures

---

## 11.4 SLO Watcher (warning logs only; no dashboards)

### Purpose

Consume telemetry v1 signals and emit `Logger.warning` when thresholds are breached.

### Implementation

`Scheduler.Obs.SLOWatcher`:

* attaches telemetry handlers (`:telemetry.attach_many/4`)
* stores rolling aggregates in ETS or state with per-minute buckets
* evaluates every `slo_eval_ms` (default 60_000)

### Required SLOs (configurable, minimal)

All evaluated over a rolling window (default 15 minutes), with optional “M consecutive breaches” (default 3) to reduce flapping.

1. **Tick budget**

* warn if `p95(tick.duration_ms) > tick_budget_ms` (default 300)

2. **Saturation**

* warn if `%samples(in_flight == max_concurrency) > sat_ratio` (default 0.8)

3. **Queue pressure**

* warn if `avg(queue.depth) > depth_avg_max` (default configurable)
* OR if `queue.depth` monotonic increase across window (simple slope check)

4. **Job latency**

* warn if `p95(job.duration_ms) > job_p95_max_ms` (default configurable)

5. **Cutoff miss rate**

* warn if `cutoff_reached / (success + cutoff_reached) > cutoff_rate_max` over window/day bucket (default configurable)

### Output

Warnings must include structured metadata:

* window length, measured value, threshold, and (when relevant) `due_bucket`.

---

## 12) Configuration (v1.1)

Scheduler:

* `tick_ms` (default 60_000)
* `max_concurrency` (K)
* `job_timeout_ms`
* `window_minutes` (fixed 60)
* `retry_delay_minutes` (fixed 10)

SLO watcher:

* `slo_eval_ms` (default 60_000)
* `slo_window_minutes` (default 15)
* thresholds: `tick_budget_ms`, `sat_ratio`, `depth_avg_max`, `job_p95_max_ms`, `cutoff_rate_max`
* `breach_consecutive` (default 3)

---

If you want, I can also provide the *exact* telemetry emission points (which function emits which event) as a short checklist, but this spec is sufficient to implement and review.
