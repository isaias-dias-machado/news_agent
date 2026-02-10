Below is an updated spec with (1) an **acceptance checklist** and (2) a **parallel work plan** that fits sub-agents/worktrees.

---

## Tiny JSONL AOL KV Store — Spec v1 (Elixir)

### Goal

A tiny, observable persistent KV store for user configuration data.

* **Persistence:** JSONL append-only log (AOL).
* **Index:** in-memory KV (`map`).
* **Durability:** `fsync` on every append.
* **Recovery:** snapshot + log replay.
* **Strictness:** corruption-in-middle causes boot crash; partial last line at EOF is ignored.
* **Compaction:** synchronous, blocks writes, triggered when active log exceeds **1MB**.
* **Rotation:** keep exactly **one** rotated log file for debugging.

### Storage layout

Data directory configurable (`:dir`), default `./data/store`.

Files:

* `snapshot.json`
* `snapshot.json.tmp` (ignore on boot)
* `ops.log.jsonl` (active)
* `ops.log.1.jsonl` (rotated debug)

### Key / identity

* `key` is a **string primary key** and the only lookup primitive.
* Recommended format: `"user:<id>"` where `<id>` is internal/stable (integer or UUID).
* Do **not** use email/phone as keys; keep them inside the value if needed.

---

## Record schema (external JSON, strict)

Each log line is one compact JSON object + `\n`.

Required:

* `"v"`: integer, must be `1`
* `"op"`: `"set"` or `"del"`
* `"key"`: string
* `"ts"`: integer (use unix ms)

For `"set"`:

* `"value"`: any JSON value (typically object/map)

For `"del"`:

* `"value"` must be absent (or ignored, but validator should reject it to keep schema clean)

Example:

```json
{"v":1,"op":"set","key":"user:1","value":{"theme":"dark"},"ts":1730000000000}
{"v":1,"op":"del","key":"user:1","ts":1730000001000}
```

### Internal representation (trusted)

* `{:set, key :: binary(), value :: map() | list() | binary() | number() | boolean() | nil, ts :: integer()}`
* `{:del, key :: binary(), ts :: integer()}`

---

## Module/API

Implement `TinyAOL.Store` as a `GenServer`.

### Public API

* `start_link(opts)`
* `get(pid, key) :: {:ok, value} | :error`
* `put(pid, key, value) :: :ok`
* `delete(pid, key) :: :ok`
* `snapshot(pid) :: :ok` (force compaction)
* `stats(pid) :: map()` (recommended)

### Options

* `:dir` (string path)
* `:compaction_bytes` default `1_048_576`
* `:fsync` default `true`
* `:timestamp_unit` fixed to `:millisecond` (or omit, just do ms)

---

## Startup / recovery behavior (strict)

On `init/1`:

1. Ensure `:dir` exists (prefer restrictive perms).
2. Ignore `snapshot.json.tmp` if present.
3. Load snapshot:

   * missing → `%{}`
   * invalid JSON → **raise**
4. Replay `ops.log.jsonl`:

   * read line-by-line
   * decode JSON and validate schema strictly
   * apply ops: `set` overwrites, `del` removes, missing key delete is no-op
   * **partial last line at EOF:** ignore and finish successfully
   * **corruption in middle:** **raise** with line number + reason
5. Open `ops.log.jsonl` append-only binary.

---

## Write path

### `put(key, value)`

1. Build record `{v:1, op:"set", key:key, value:value, ts:now_ms}`
2. Encode compact JSON line + `\n`
3. Append to `ops.log.jsonl`
4. If `:fsync` true → `File.sync/1`
5. Update in-memory `Map.put`
6. If `file_size(ops.log.jsonl) > compaction_bytes` → run compaction synchronously

### `delete(key)`

Same, with `"del"` and no `"value"`, then `Map.delete`.

**Concurrency:** single writer; during compaction, all calls queue (block).

---

## Compaction / snapshot (synchronous, blocks)

Triggered automatically by size or manually via `snapshot/1`.

Steps:

1. `File.sync(log_fd)` (safe even if already synced)
2. Write full in-memory KV to `snapshot.json.tmp` (single JSON object)
3. `File.sync(snapshot_fd)` and close
4. `File.rename(snapshot.json.tmp, snapshot.json)` (atomic)
5. Rotate logs:

   * close log fd
   * delete `ops.log.1.jsonl` if exists
   * rename `ops.log.jsonl` → `ops.log.1.jsonl` (if exists)
   * create/open new empty `ops.log.jsonl`
6. Update `stats` metadata (last snapshot time, counts, sizes)

**Failure policy:** any error in compaction → **raise** (strict).

---

# Acceptance checklist

These are hands-on checks you (or a sub-agent) can run locally. The goal is to validate correctness *without* reading code.

## A) Basic functionality

1. Start store with empty dir → `stats` shows 0 keys, files created as expected.
2. `put("user:1", %{...})`, `get("user:1")` returns same value.
3. `delete("user:1")` then `get` returns `:error`.

## B) Persistence across restart

1. Start store, `put user:1`, `put user:2`.
2. Stop store cleanly.
3. Restart store pointing at same dir.
4. `get user:1` and `get user:2` succeed and match.

## C) Replay semantics (last write wins)

1. `put user:1 -> A`
2. `put user:1 -> B`
3. Restart
4. `get user:1 == B`

## D) Partial last line handling

1. Make some writes.
2. Manually truncate last bytes of `ops.log.jsonl` (simulate power loss mid-write).
3. Restart store:

   * must start successfully
   * state reflects all ops *except* the truncated last op

## E) Corruption in the middle is strict

1. Insert an invalid JSON line in the middle of `ops.log.jsonl` (not the last line).
2. Restart store:

   * must **crash/fail fast**
   * error message includes line number and reason

## F) Compaction trigger and correctness

1. Write enough ops to exceed 1MB (or set `compaction_bytes` low during test).
2. Observe:

   * `snapshot.json` created/updated
   * `ops.log.jsonl` becomes small/empty after compaction
   * `ops.log.1.jsonl` exists
3. Restart store:

   * state matches pre-restart state exactly

## G) Rotation keeps exactly one debug log

1. Force compaction twice.
2. Ensure only one rotated log exists (`ops.log.1.jsonl`), not `.2`, etc.

## H) Blocking behavior during compaction

1. Artificially slow snapshot write (agent can add optional test hook or use very low disk throughput).
2. Concurrently call `put` from another process.
3. Confirm `put` returns only after compaction completes (no interleaving/corruption).

---

# Parallel work plan for MCP sub-agents/worktrees

Split into 4 parallel tracks with clean boundaries.

## Worktree 1 — Core GenServer + state machine

Deliverables:

* `TinyAOL.Store` public API
* state struct (dir paths, map, fd, config, stats)
* synchronous compaction orchestration (calls out to helpers)

## Worktree 2 — Codec + validator (strict schema)

Deliverables:

* `TinyAOL.Codec.encode_op/1` and `decode_line!/2`
* strict validation rules (v/op/key/value/ts)
* “partial last line at EOF” detection strategy for replay helper

## Worktree 3 — Filesystem helpers (atomicity + rotation)

Deliverables:

* `write_snapshot_tmp/2`, `atomic_replace_snapshot/1`
* `rotate_logs/1` keep only `.1`
* open/close fd helpers
* log size function (stat)

## Worktree 4 — Tests + acceptance harness

Deliverables:

* ExUnit tests covering A–G above
* helper functions to truncate/corrupt log files
* optional small CLI mix task: `mix tiny_aol.smoke DIR` that runs the acceptance steps quickly

Integration rule:

* Core calls codec + fs helpers; tests treat store as black box.

---

# Directory structure

I want a public context module that other modules can call: lib/storage.ex
The internals for the system should be written in lib/storage/
