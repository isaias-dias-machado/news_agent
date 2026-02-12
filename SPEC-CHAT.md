# Implementation SPEC — Chat Boundary (v1)

## Objective

Provide a boundary for Telegram chat onboarding and LLM interaction that polls queued bot updates, routes user input through in-memory session state, and delivers replies back to the originating chat. Support a reset-and-reseed flow that clears the current LLM context, loads stored content, and starts a new Gemini-backed chat with a content-primed system prompt.

---

## Contract

Callers provide Telegram updates (or invoke polling) and receive responses delivered to the originating chat. The boundary pulls from the in-memory bot queue, calls the Telegram API for responses, keeps onboarding state in memory, and routes user input to the configured LLM provider. Delivery depends on external services; callers should expect transient failures and poll frequently enough to avoid backlog growth. A reset-and-reseed call clears the in-memory context, loads stored content for the user, builds a new system prompt, calls Gemini, and starts a new chat turn with the user.

---

## Out of Scope (v1)

Persistence of chat context, durable queueing, multi-node coordination, delivery retries beyond Telegram adapter behavior, automatic content ingestion (this flow reads already-stored content), and LLM provider selection logic outside the reset-and-reseed path.

---

## Data Flow

1. `poll/1` pulls updates from the Telegram bot in-memory queue.
2. Each update is normalized into a chat message by extracting `chat_id`.
3. `Session.handle_update/3` computes reply and status using in-memory state + LLM routing.
4. `TelegramBot.send_message/3` delivers the reply when enabled and non-empty.
5. `reset_with_content/2` clears history, loads stored content records, builds a new system prompt, calls Gemini, and returns the first reply for a new chat.

---

## Public API

`poll(opts \ []) :: {:ok, non_neg_integer()} | {:error, term()}`

- Dequeues up to `:limit` updates (default 25) and handles them sequentially.
- Returns count of updates that produced `{:ok, _}`.

`handle_update(update, opts \ []) :: {:ok, map()} | {:error, term()}`

- Extracts `chat_id` from supported Telegram update fields.
- Delegates to session handling and sends reply (unless disabled).

`reset_context(chat_id, opts \ []) :: :ok | {:error, term()}`

- Clears in-memory chat context for a chat id.

`reset_with_content(chat_id, opts \\ []) :: {:ok, map()} | {:error, term()}`

- Clears in-memory history, loads stored content for the resolved user id, injects it into a fresh system prompt, calls Gemini, and returns the first assistant reply.
- Starts a new chat turn; the resulting reply is appended as the first assistant entry in history.

---

## Error Handling

- Missing `chat_id` yields `{:error, :missing_chat_id}`.
- Session or Telegram adapter failures are returned as `{:error, reason}`.
- `poll/1` does not stop on per-update errors; it counts only successful handles.
- Content storage failures return `{:error, reason}` (including `:invalid_user_id`, `:invalid_slug`, `:invalid_content`, or filesystem errors).
- Gemini or LLM call failures return `{:error, reason}`; history must remain reset (empty) if the reseed attempt fails.

---

## Dependencies

- `NewsAgent.Chat.Session` for onboarding state and LLM routing.
- `NewsAgent.TelegramBot` for dequeuing updates and sending messages.
- `NewsAgent.ContentStorage` for loading stored content records.
- `NewsAgent.Chat.LLM.Gemini` (or Gemini boundary) for the reseed call.

---

## Invariants / Behavior

- `chat_id` is normalized to string before session usage or delivery.
- Replies are sent only when non-empty and `:send?` is true.
- Updates are handled in the order they are dequeued.
- Reseed flow clears history before loading content and before invoking Gemini.
- Reseed flow must not write partial history on failures (either empty or the new first reply).
- Prompt size logging must be emitted before the Gemini call.

---

## Observability / Logging Expectations

Prompt-size logging is required for the reseed flow and must include `chat_id`, `user_id`, `content_count`, `prompt_size`, and `limit`.

Thresholds are calculated as ratios of the configured limit:

- `debug` when `prompt_size <= 0.40 * limit`
- `info` when `0.40 * limit < prompt_size <= 0.70 * limit`
- `warning` when `0.70 * limit < prompt_size <= limit`
- `error` when `prompt_size > limit` (exceeds model recommended context window)

---

## Configuration

Runtime options:

- `:limit` (polling) default 25.
- `:send?` (delivery) default true.
- `NEWS_AGENT_CHAT_CONTEXT_LIMIT_CHARS` sets the reseed prompt size limit (characters), used to derive the logging thresholds.

Adapter configuration for Telegram and LLM providers is handled outside this boundary.

---

## Validation Conditions (Sub-Agent Iteration)

- Spec defines `reset_with_content/2` with return shape and failure semantics.
- Data flow explicitly states: clear history -> load content -> build prompt -> call Gemini -> append first reply.
- Invariants include "clear before load" and "no partial history on failure".
- Dependencies list includes `NewsAgent.ContentStorage` and Gemini boundary/provider for reseed.
- Error handling includes content read failures and Gemini failures, with history left empty on failure.
- Observability rules include required metadata (`chat_id`, `user_id`, `content_count`, `prompt_size`, `limit`).
- Thresholds are expressed as ratios of the configurable limit and map to debug/info/warn/error.
- Config entry `NEWS_AGENT_CHAT_CONTEXT_LIMIT_CHARS` is documented and used to derive thresholds.
- Reset-and-reseed behavior does not conflict with `/reset` or session expiry semantics.
