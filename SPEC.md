# News Digest PoC - High Level Spec

## Objective
Build a minimal Elixir server that produces a daily news digest from configured sources and delivers it to users via Telegram. The server owns configuration, fetching, heuristics, LLM prompting, summarization, and filesystem persistence. Telegram is the messaging surface only.

## Scope
- Provide a daily digest of items from configured sources (YouTube RSS, blogs, online newspapers).
- Store fetched content and summaries in the filesystem-backed content store.
- Generate digest responses on demand using the LLM and store them in chat memory.
- Allow users to request details about an item after reading the digest.

## Non-Goals (PoC)
- No database; filesystem only.
- No web UI.
- No multi-tenant user management beyond a minimal per-user configuration model.
- No advanced ranking models or personalization beyond simple heuristics.

## System Responsibilities

### Elixir Server
- Owns user configuration and source lists.
- Fetches source data (RSS/Atom, optional HTML where needed).
- Applies heuristics (time window, simple ranking, deduplication).
- Prompts LLM provider for summaries and stores results.
- Serves digest and item detail responses to Telegram requests.

### Telegram
- Provides a chat channel for inbound commands and outbound replies.
- No business logic; only message transport.

## High-Level Architecture
- Telegram Bot API integration in Elixir (long polling recommended for PoC).
- Source fetchers:
  - YouTube RSS/Atom feed per channel (resolve channel ID when needed).
  - Generic RSS/Atom for blogs/news sites.
  - Optional HTML fetcher for sources without feeds (PoC only if required).
- Digest pipeline:
  - Collect new items in a time window.
  - Deduplicate by URL and title.
  - Summarize with LLM provider.
  - Persist summaries in content storage; generate digests on demand.

## Data Flow
1) User sends a command (e.g., "daily") via Telegram.
2) Elixir server fetches sources for the user if needed.
3) Elixir server filters and summarizes items, persists results to content storage.
4) Elixir server asks the LLM to generate a digest response from stored content and sends it to Telegram.
5) User asks for details (e.g., "details <id>").
6) Elixir server loads item summary and responds with details.

## Storage (Filesystem)
- data/users/<user_id>/sources/*.json
  - per-source summaries and metadata (content storage)
- Chat context is kept in memory (history persisted only by the chat session process).

## Configuration
- Source list per user (YouTube channels, RSS URLs, optional HTML URLs).
- Digest window (default: last 24 hours or since midnight UTC).
- LLM provider credentials (via runtime config / env vars).

## Telegram Interface (Proposed)
- Commands:
  - daily: returns latest digest
  - details <id>: returns detailed summary for a single item
- Delivery method: long polling for PoC (webhook optional later).

## Milestones
1) Telegram Bot API integration (polling + send message).
2) YouTube RSS fetcher and URL extraction.
3) Generic RSS/Atom fetcher.
4) Digest builder with time window + dedup.
5) LLM summarization and content storage.
6) Details lookup by item id.

## Open Questions
- Final LLM provider choice and prompt style.
- Digest schedule: on-demand vs scheduled daily.
- Exact source scope for PoC (RSS-only vs RSS + HTML).
