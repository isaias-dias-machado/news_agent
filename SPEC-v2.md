# News Digest MVP - Spec v2

## Objective

Deliver a daily YouTube-only news digest to each user at their configured UTC `due_time`, using the scheduler. The digest is generated on demand from stored per-item summaries and sent via Telegram. No digest files are persisted.

## Scope (MVP)

- **Url strategy filtering:** YouTube RSS/Atom only.
- **Delivery:** Scheduler-driven daily delivery per user `due_time` (UTC).
- **Storage:** Per-item summaries persisted via content storage (`data/users/<user_id>/sources/*.json`).
- **Digest:** Generated on demand using the LLM; stored only in chat memory.
- **Telegram:** Send digest to linked chat; optional `details <id>` lookup.

## Non-Goals

- Generic RSS/Atom and HTML scraping.
- Persisted digest files or indexes.
- Web UI.
- Multi-node scheduling.

## Data Flow (Daily)

1. Scheduler tick scans users; when in window, enqueues job.
2. Job runner uses the url router to figure out which module to use to scrape
   content.
3. Job runner fetches YouTube RSS items for the user’s configured channels.
4. Items are filtered by time window (last 24h or since midnight UTC).
5. Items are deduped by normalized URL.
6. Summaries are generated and stored in content storage.
7. LLM generates a digest response from stored summaries.
8. Telegram bot sends the digest to the user’s linked chat.
9. At cutoff, chat context is reset so the next day starts fresh.

## Storage

- **Content storage only:** `data/users/<user_id>/sources/*.json`
- **Chat memory only:** in-memory session history per chat.
- **UserConfigs**: KV store AOL backed.

## Configuration

- Per-user `due_time` (UTC), configured in `UserConfigs`.
- Per-user url source list (`url_sources`).
- LLM provider credentials (runtime config).

## Telegram Interface (MVP)

- No `/daily` command required (scheduler-only).
- Optional `details <id>` if details lookup is implemented.

## Milestones

1. Job runner: YouTube fetch + filter + summarize + digest LLM output.
2. Scheduler integration: deliver at `due_time`.
3. Telegram send of digest.
4. Optional details lookup.

## Open Questions

- Digest prompt format and maximum length.
- Item id scheme for details lookup (if kept).
- Window definition (last 24h vs midnight UTC).
