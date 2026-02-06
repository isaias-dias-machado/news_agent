## Development environment

This project uses the dev-env-mcp MCP server. Plugin commands live in `dev_env.json`.

### Setup flow (dev-env-mcp)

1) Run `dev-env-mcp` from the repo root.
2) Call `project.setup` once to create `workspaces/` and update gitignore.
3) Create/select a workspace with `workspace.create` and `workspace.select`.
4) Start all plugins with `env.start`.
5) Use `env.status` and `env.logs` to inspect runtime details.

### Usage

IMPORTANT: you should not do work, you are the "planer". start a "builder" sub-agent in the workspace directory.
After iterations, always commit fixes so I can diff them from the master branch

### Required environment

Telegram MTProto user bridge:

- `TELEGRAM_API_ID`
- `TELEGRAM_API_HASH`
- `TELEGRAM_PHONE`

Optional (bridge):

- `TELEGRAM_LOGIN_CODE` (non-interactive login)
- `TELEGRAM_SESSION_DIR` (defaults to `services/telegram_https_client_bridge/session`)
- `TELEGRAM_BRIDGE_PORT` (defaults to `8081`)

Telegram bot server:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_BOT_SERVER_PORT` (defaults to `8090`)

### Telegram bridge image

Build the Docker image before starting the env:

```bash
docker build -t telegram_https_client_bridge services/telegram_https_client_bridge
```

The `telegram_bot_server` plugin runs the container with port 8088 bound to localhost and persists sessions under `services/telegram_https_client_bridge/session`.

### Bridge HTTP endpoints

- `POST http://127.0.0.1:8088/send` with JSON `{ "peer": "@bot", "text": "..." }`
- `GET http://127.0.0.1:8088/updates?peer=@bot`

### Bot server HTTP endpoints

- `POST http://127.0.0.1:8090/register` with JSON `{ "workspace_id": "alpha", "chat_ids": [123456] }`
- `GET http://127.0.0.1:8090/queue?workspace_id=alpha&limit=25`
