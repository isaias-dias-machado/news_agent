# Content Storage Spec

## Goal
Persist per-user, per-source content on disk in a simple, observable format with
durable daily overwrites.

## Storage layout
- Base directory: `data/users/<user_id>/sources/`
- One file per source: `<slug>--<base32(url)>.json`
  - `slug` is a human-readable identifier (user-provided or derived).
  - `base32(url)` is the Base32 encoding of the source URL string.
  - The separator `--` is fixed and must not appear in the slug.

## JSON schema
Each file contains a single JSON object with the following fields:

```json
{
  "content_url": "https://example.com/article",
  "normalized_url": "https://example.com/article",
  "author": "Author Name",
  "content": "Full content body...",
  "fetched_at": "2026-02-11T13:12:45Z"
}
```

Field requirements:
- `content_url` (string, required): the original URL.
- `normalized_url` (string, required): output of `NewsAgent.Sources.normalize_url/1`.
  - Host lowercased, fragment removed, scheme/path/query preserved.
- `author` (string, required): author display name (can be empty if unknown).
- `content` (string, required): full content body.
- `fetched_at` (string, required): ISO8601 UTC timestamp (from `DateTime.utc_now/0`).

## Write semantics
- Writes are idempotent and overwrite the existing file for the same source.
- TTL is implicit: the daily cron overwrites each source file.

## Durability
Writes must be atomic and durable using `:file.sync/1`:
1) Write JSON to `*.tmp` in the same directory.
2) Call `:file.sync/1` on the temp file descriptor.
3) Rename `*.tmp` to `*.json` (atomic on same filesystem).

If a crash occurs during write, the previous `*.json` remains valid. Any leftover
`*.tmp` files are ignored and can be cleaned up opportunistically.

## Read semantics
- Read the `*.json` file and decode as JSON.
- Validate required keys and types; reject malformed files.

## Observability
- Each source is a separate, human-inspectable file.
- Directory structure reflects user and source boundaries.

## Constraints
- No JSONL aggregation.
- No global index file required.
- File paths must be derived solely from `user_id`, `slug`, and `content_url`.
