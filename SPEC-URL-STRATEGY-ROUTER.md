# URL Strategy Router MVP Spec

## Purpose

Define the MVP routing layer that classifies a URL into a retrieval strategy without persisting any data. The router performs minimal, safe HTTP interaction to identify YouTube or feed (RSS/Atom) sources, otherwise returns a standardized error.

## Module

- Module name: `NewsAgent.UrlStrategyRouter`
- Responsibility: normalize URL, validate safety constraints, classify via routing order, and return a strategy descriptor or error.
- Non-responsibilities: fetching items, parsing content, persistence, or scheduling.

## Public API

```
@spec classify(String.t(), keyword()) ::
  {:ok, strategy_map} | {:error, :not_supported | :invalid_url | :blocked_host | :too_long}
```

- Input: raw URL string, optional keyword options (timeouts, max length, allow_private).
- Output: `{:ok, strategy_map}` where strategy_map is defined by the strategy behavior contract, or error tuple.

## Strategy Behavior Contract

All strategy modules must implement:

```
@callback match?(URI.t(), keyword()) :: boolean()
@callback classify(URI.t(), keyword()) :: {:ok, strategy_map} | {:error, :not_supported}
```

Strategy map shape (minimum):

```
%{
  type: :youtube | :feed,
  source_url: String.t(),
  canonical_url: String.t(),
  confidence: float()
}
```

- `match?/2` should be fast and side-effect free.
- `classify/2` may perform lightweight HTTP interaction (Req) but must not retrieve items.
- If a strategy cannot confirm, it returns `{:error, :not_supported}`.

## Routing Order

1) YouTube strategy
2) RSS/Atom feed strategy
3) Fallback: `{:error, :not_supported}`

The router must stop at the first strategy that returns `{:ok, strategy_map}`.

## On-the-fly Classification (HTTP)

- Use `Req` for HTTP interaction only when needed to confirm a feed.
- Prefer `HEAD` then `GET` if needed; cap response body to a small limit (e.g., first 64KB).
- Do not follow more than a small redirect chain (e.g., 3).

### Feed Detection

Feed classification is confirmed when both of the following are satisfied:

- `content-type` indicates XML or RSS/Atom (e.g., `application/rss+xml`, `application/atom+xml`, `application/xml`, `text/xml`).
- The root element is `<rss>` (RSS 2.0) or `<feed>` (Atom). Only the root tag check is required for MVP.

If either check fails, return `{:error, :not_supported}`.

### YouTube Detection

- Match against known YouTube hostnames and URL patterns without HTTP calls.
- If pattern matches, return `{:ok, strategy_map}` with `type: :youtube`.

## URL Normalization and Security Constraints

- Accept only `http` and `https` schemes. Anything else is `{:error, :invalid_url}`.
- Normalize scheme and host to lowercase.
- Strip default ports (`:80` for http, `:443` for https).
- Cap normalized URL length (default 2048). Exceeding is `{:error, :too_long}`.
- When running server-side, block private, loopback, and link-local IP ranges and `localhost` unless explicitly allowed via options; return `{:error, :blocked_host}`.
- Preserve path and query; do not normalize query ordering in MVP.

## Classification vs Retrieval Separation

- Classification only determines strategy. It must not fetch or parse content items.
- Retrieval is owned by downstream strategy executors, not this router.

## Logging and Timing

- Measure routing duration and log a single debug line on completion.
- Log format (string template):

```
"url_strategy_router route finished url=<url> result=<result> duration_ms=<ms>"
```

- `result` should be `ok:<type>` or `error:<reason>`.
- Timing uses monotonic time; duration in integer milliseconds.

## Constraints

- No persistence in this module.
- No filesystem writes.
- No network calls except minimal HTTP classification for feed detection.
- Only `Req` for HTTP.
- ASCII-only output in this spec.

## Acceptance Criteria

- Given a YouTube URL, `classify/2` returns `{:ok, %{type: :youtube, ...}}` without HTTP calls.
- Given a valid RSS/Atom URL, `classify/2` confirms via content-type and root element and returns `{:ok, %{type: :feed, ...}}`.
- Given a non-feed URL, router returns `{:error, :not_supported}`.
- Given an invalid scheme or malformed URL, router returns `{:error, :invalid_url}`.
- Given a private or localhost target while server-side and not allowed, router returns `{:error, :blocked_host}`.
- Normalization lowercases scheme/host and strips default ports.
- Routing order is YouTube then Feed, then error.
- A single debug log entry is emitted per classify call with duration and result.
