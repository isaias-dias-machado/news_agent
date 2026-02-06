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
- `TELEGRAM_SESSION_DIR` (defaults to `images/telegram-TDLib/session`)
- `TELEGRAM_BRIDGE_PORT` (defaults to `8081`)

Elixir app:

- `TELEGRAM_BOT_TOKEN`
- `TELEGRAM_BOT_NAME` (used as the default bot handle for bridge tests)

### Telegram bridge image

Build the Docker image before starting the env:

```bash
docker build -t telegram_tdlib_bridge -f images/telegram-TDLib/Dockerfile .
```

The `telegram_user_bridge` plugin runs the container with port 8081 bound to localhost and persists sessions under `images/telegram-TDLib/session`.

### Bridge HTTP endpoints

- `POST http://127.0.0.1:8081/send` with JSON `{ "peer": "@bot", "text": "..." }`
- `GET http://127.0.0.1:8081/updates?peer=@bot`

## Merging into master branch

Push feature branch → update main workspace → squash merge from remote branch into main.

## Documentation & Boundary Contracts

- **Internal Implementation:** No comments allowed in internal logic or private functions.
- **Context Boundaries:** You MUST write `@moduledoc`, `@doc`, and `@spec` for modules serving as Context boundaries (e.g., `MyApp.Accounts`).
- **Content:** Documentation at these boundaries must describe the **tensions** and the **contract** the caller is subscribing to (e.g., side effects, data consistency guarantees, or expected caller-side validations).

## asdf in non-interactive shells

In non-interactive shells, the `asdf` shims directory may not be on `PATH`, so `mix` is not found.
Use:

```
export PATH="$HOME/.asdf/shims:$PATH"
```

Then run `mix` commands (e.g. `mix precommit`).

## Project guidelines

- Use `mix precommit` alias when you are done with all changes and fix any pending issues
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

## Test guidelines

- **Always use `start_supervised!/1`** to start processes in tests as it guarantees cleanup between tests
- **Avoid** `Process.sleep/1` and `Process.alive?/1` in tests
  - Instead of sleeping to wait for a process to finish, **always** use `Process.monitor/1` and assert on the DOWN message:

      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, :process, ^pid, :normal}

  - Instead of sleeping to synchronize before the next call, **always** use `_ = :sys.get_state/1` to ensure the process has handled prior messages
<!-- phoenix:elixir-end -->
