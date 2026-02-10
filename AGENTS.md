## Dev environment usage

To use dedicated dev envs for fixes and new feature, which you should, learn the
stdio mcp tool by running `dev-env-mcp --help`.

 Use env.status after selecting the workspace; the status output includes the plugin’s env
  map (stored when the process is started). That’s where PORT will be if it’s set in
  dev_env.json or passed via overrides.

  Example flow (conceptual):

- call workspace.select with the workspace name
- call env.status
- find the entry for your server plugin (often named server)
- read env.PORT

  If the plugin hasn’t been started yet, env.status won’t have env.PORT (it only captures env
  when starting). In that case, the agent should either:

- read the port from dev_env.json, or
- start the env with an override and then read it back via env.status.

## Development environment

This project uses the dev-env-mcp MCP server. Plugin commands live in `dev_env.json`.

### Setup flow (dev-env-mcp)

1) Run `dev-env-mcp` from the repo root.
2) Call `project.setup` once to create `workspaces/` and update gitignore.
3) Create/select a workspace with `workspace.create` and `workspace.select`.
4) Start all plugins with `env.start`.
5) Use `env.status` and `env.logs` to inspect runtime details.

IMPORTANT: writing to the master branch or project root workspace is forbidden.

### Usage

IMPORTANT: you should not do work, you are the "planer". start a "builder" sub-agent in the workspace directory.
The main agent owns workspace creation/selection and can create as many workspaces as needed. For each workspace, spawn exactly one sub-agent with its workdir set to that workspace root to promote parallelism and isolation.

### Required environment

Telegram MTProto user bridge:

- `TELEGRAM_API_ID`
- `TELEGRAM_API_HASH`
- `TELEGRAM_PHONE`

Optional (bridge):

- `TELEGRAM_LOGIN_CODE` (non-interactive login)
- `TELEGRAM_SESSION_DIR` (defaults to `services/telegram_https_client_bridge/session`)
- `TELEGRAM_BRIDGE_PORT` (defaults to `8081`)

Telegram bot:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_BOT_NAME` (used as the default bot handle for bridge tests)

### Telegram bot mocking

Set `NEWS_AGENT_TELEGRAM_MODE` to switch adapters at runtime:

- `NEWS_AGENT_TELEGRAM_MODE=mock` (default) uses the in-memory mock adapter for tests.
- `NEWS_AGENT_TELEGRAM_MODE=real` uses the real Telegram HTTP API.

The mock adapter stores queued updates and sent messages in memory. Use
`NewsAgent.TelegramBot.Adapter.Mock.enqueue_update/1`,
`NewsAgent.TelegramBot.Adapter.Mock.sent_messages/0`, and
`NewsAgent.TelegramBot.Adapter.Mock.reset/0` in tests to control state.

### Telegram bridge image

Build the Docker image before starting the env:

```bash
docker build -t telegram_https_client_bridge services/telegram_https_client_bridge
```

The `telegram_https_client_bridge` plugin runs the container with port 8088 bound to localhost and persists sessions under `services/telegram_https_client_bridge/session`.

### Bridge HTTP endpoints

- `POST http://127.0.0.1:8088/send` with JSON `{ "peer": "@$TELEGRAM_BOT_NAME", "text": "..." }`
- `GET http://127.0.0.1:8088/updates?peer=@$TELEGRAM_BOT_NAME`

## Committing and Merging into master branch

IMPORTANT: the `.commit-message-stash` should be the basis for the body of the commit message

Push feature branch → update main workspace → squash merge from remote branch into main.

## Iteration and testing

IMPORTANT: When implementing features you should try to test them using their top level public API, if the code is not behaving as expected you should try to fix it before stopping.
IMPORTANT: Maintain a temporary document on the workspace under the `.commit-message-stash` directory that should include only the steps that validated the feature or fix.
IMPORTANT: Do not include failed or exploratory test attempts in the `.commit-message-stash` notes.

## Observing persisted data

To inspect DETS-backed KV data during manual testing:

1) Persist a record via the public API:

```
source "$HOME/.env"
export PATH="$HOME/.asdf/shims:$PATH"
mix run -e 'canonical = "https://example.com/feed"; strategy = %{strategy: %{type: "feed", source_url: canonical}, confidence: 0.9, last_verified_at: DateTime.utc_now()}; IO.inspect(NewsAgent.Sources.persist_strategy(canonical, strategy))'
```

1) Verify the DETS file exists:

```
ls -l data/kv/source_strategies.dets
```

1) Inspect stored entries:

```
mix run -e '{:ok, table} = NewsAgent.KVStore.open(:source_strategies); entries = NewsAgent.KVStore.all(table); IO.inspect(entries); _ = NewsAgent.KVStore.close(table)'
```

1) Dump a tree view with `mix kv.dump` (defaults to all tables). Use `--table` to target one table and `--limit` to cap entries.

```
mix kv.dump
mix kv.dump --table source_strategies
mix kv.dump --table source_strategies --limit 25
```

### Manual testing workflow

All manual testing workflows must be registered here.

ManualTesting transcript capture:

```
source "$HOME/.env"
export PATH="$HOME/.asdf/shims:$PATH"
mix run -e 'IO.inspect(NewsAgent.ManualTesting.run("https://youtu.be/VM5MjVALMGc?si=pkj1Yw52Ff4bKNEY"))'
```

## Documentation & Boundary Contracts

- **Internal Implementation:** No comments allowed in internal logic or private functions.
- Every module should have a @moduledoc describing what it does and how it fits inside a context
- **Context Boundaries:** You MUST write `@moduledoc`, `@doc`, and `@spec` for modules serving as Context boundaries (e.g., `MyApp.Accounts`).
- **Content:** Documentation at these boundaries must describe the **tensions** and the **contract** the caller is subscribing to (e.g., side effects, data consistency guarantees, or expected caller-side validations).

## asdf in non-interactive shells

In non-interactive shells, the `asdf` shims directory may not be on `PATH`, so `mix` is not found.
Use:

```
export PATH="$HOME/.asdf/shims:$PATH"
```

## Project guidelines

- Use the already included and available `:req` (`Req`) library for HTTP requests, **avoid** `:httpoison`, `:tesla`, and `:httpc`. Req is included by default and is the preferred HTTP client for Phoenix apps

<!-- phoenix:elixir-start -->
## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc
  you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark. Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option

## Mix guidelines

- Read the docs and options before using tasks (by using `mix help task_name`)
- To debug test failures, run tests in a specific file with `mix test test/my_test.exs` or run all previously failed tests with `mix test --failed`
- `mix deps.clean --all` is **almost never needed**. **Avoid** using it unless you have good reason
- To discover available documentation in the project, use `mix help` to list tasks and `mix help <task>` for task docs. For Elixir module docs, prefer `mix help Module[.Function[.Arity]]` and only search the web when module docs are unavailable.

## Test guidelines

- **Always use `start_supervised!/1`** to start processes in tests as it guarantees cleanup between tests
- **Avoid** `Process.sleep/1` and `Process.alive?/1` in tests
  - Instead of sleeping to wait for a process to finish, **always** use `Process.monitor/1` and assert on the DOWN message:

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, :process, ^pid, :normal}

  - Instead of sleeping to synchronize before the next call, **always** use `_ = :sys.get_state/1` to ensure the process has handled prior messages
<!-- phoenix:elixir-end -->
