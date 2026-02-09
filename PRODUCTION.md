# Production Configuration

This document lists runtime configuration for deploying NewsAgent.

## Required

- `NEWS_AGENT_TELEGRAM_MODE=real`
  - Uses the real Telegram Bot API adapter. Default is `mock` if unset.
- `TELEGRAM_BOT_TOKEN`
  - Telegram bot token used for sending messages and polling updates.
- `GEMINI_API_KEY`
  - Required for Gemini LLM calls.
- `TRANSCRIPT_API_KEY`
  - Required for YouTube transcript fetching.

## Recommended

- `NEWS_AGENT_CHAT_LLM_TIMEOUT_MS`
  - LLM call timeout in milliseconds (default 4000). Increase for production latency.

## Optional

- `TELEGRAM_BOT_POLL_TIMEOUT`
  - Long-poll timeout in seconds for fetching Telegram updates (default 30).
- `TELEGRAM_BOT_ALLOWED_UPDATES`
  - Comma-separated list of Telegram update types to request.
  - Default: `message,edited_message,channel_post`.
- `NEWS_AGENT_CHAT_POLL_INTERVAL_MS`
  - Interval for the internal chat poller (default 500).
- `NEWS_AGENT_CHAT_POLL_ERROR_INTERVAL_MS`
  - Poller interval after errors (default 250).
- `NEWS_AGENT_CHAT_HISTORY_MAX`
  - Max history length stored per chat session (default 20).
- `NEWS_AGENT_DEFAULT_USER`
  - Default user id for linking chats when no user is provided (default `isaias`).
- `NEWS_AGENT_ENV=dev`
  - Enables dev-specific behavior (only use in non-production environments).
