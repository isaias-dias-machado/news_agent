# Telegram MTProto User Bridge

This bridge runs a local HTTP server that sends messages as your Telegram user
and reads replies from a bot. It uses MTProto via Telethon.

## Setup

1) Create API credentials at https://my.telegram.org
2) Export required env vars:

```bash
export TELEGRAM_API_ID=...
export TELEGRAM_API_HASH=...
export TELEGRAM_PHONE=+351...
```

Optional:

```bash
export TELEGRAM_PASSWORD=...           # only if you use 2FA
export TELEGRAM_LOGIN_CODE=...         # for non-interactive login
export TELEGRAM_LOGIN_PASSWORD=...     # 2FA password for non-interactive login
export TELEGRAM_SESSION_DIR=/path/...  # default is images/telegram-TDLib/session
export TELEGRAM_BRIDGE_PORT=8081
```

3) Run in Docker (no local Python needed):

```bash
docker compose -f images/telegram-TDLib/docker-compose.yml up --build
```

You'll be prompted for the login code on first run in the container terminal.

## Usage

Send a message to your bot (user -> bot):

```bash
curl -s -X POST http://127.0.0.1:8081/send \
  -H "Content-Type: application/json" \
  -d '{"peer":"@your_bot_username","text":"hello"}'
```

Read bot replies (bot -> user):

```bash
curl -s "http://127.0.0.1:8081/updates?peer=@your_bot_username"
```

Use `after_id` to only fetch messages after a known id:

```bash
curl -s "http://127.0.0.1:8081/updates?peer=@your_bot_username&after_id=12345"
```
