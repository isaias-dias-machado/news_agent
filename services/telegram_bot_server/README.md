# Telegram Bot Server

This service polls the Telegram Bot API and routes updates into per-workspace
queues that the core application can poll.

## Environment

Required:

- `TELEGRAM_BOT_TOKEN`

Optional:

- `TELEGRAM_BOT_SERVER_HOST` (default `0.0.0.0`)
- `TELEGRAM_BOT_SERVER_PORT` (default `8090`)
- `TELEGRAM_BOT_POLL_TIMEOUT` (default `30`)
- `TELEGRAM_BOT_ALLOWED_UPDATES` (default `message,edited_message,channel_post`)
- `TELEGRAM_BOT_QUEUE_LIMIT` (default `25`)
- `TELEGRAM_BOT_QUEUE_MAX_LIMIT` (default `200`)

## HTTP API

Register chat ownership:

```bash
curl -s -X POST http://127.0.0.1:8090/register \
  -H "Content-Type: application/json" \
  -d '{"workspace_id":"alpha","chat_ids":[123456]}'
```

Poll messages:

```bash
curl -s "http://127.0.0.1:8090/queue?workspace_id=alpha&limit=25"
```
