# Job Runner Spec (MVP)

## Purpose
`NewsAgent.Scheduler.JobRunner` executes the daily digest pipeline for a single user and returns `:ok | {:error, term}`. It must be idempotent for the day and respect scheduler retry policy (no internal retries).

## Inputs
- `user_id`
- `today` (UTC date string, "YYYY-MM-DD")

## Outputs
- `:ok` on success
- `{:error, term}` on failure (no retries inside the runner)

## Required Behavior
1. **Load user config**
   - Fetch `UserConfigs.get(user_id)`.
   - Ensure `url_sources` is present and only YouTube sources are used.
   - Ensure `chat_id` is present; otherwise return `{:error, :missing_chat_id}`.

2. **Fetch YouTube RSS items**
   - For each configured YouTube source URL:
     - Resolve to YouTube RSS feed.
     - Fetch feed and extract items with title, URL, published time.

3. **Filter by time window**
   - Include only items in the window (default last 24h or since midnight UTC).

4. **Deduplicate**
   - Dedup by normalized URL (case-insensitive, strip fragments).

5. **Summarize and store**
   - For each item, generate a summary (LLM or lightweight).
   - Store summary via `ContentStorage.store/5` keyed by user and source slug.

6. **Generate digest response**
   - Read stored summaries for the user.
   - Build an LLM prompt to compose the digest message.
   - Generate digest response text (single LLM call).

7. **Deliver via Telegram**
   - Send the digest to the user’s linked `chat_id`.

## Failure Handling
- Any failure returns `{:error, term}`.
- No internal retries.
- Scheduler handles retry via window rules.

## Telemetry
- The executor already wraps jobs with `[:sched, :job]` span; no additional telemetry required in the runner.

## Notes
- Only YouTube sources are supported in MVP.
- Digest text is not persisted; only per-item summaries are stored.
- Chat context reset happens on cutoff (handled by scheduler finalization).
