# YouTube Transcript Service

FastAPI microservice that retrieves YouTube captions (no ASR fallback).

## Caption selection

- If a language is provided: manual captions first, then auto-generated for that language.
- If no language is provided: English manual, then English auto-generated.
- If English is unavailable: first available manual, then first available auto-generated.
- No auto-translation is used.

## Build

```bash
docker build -t youtube_transcript_service .
```

## Run

```bash
docker run --rm -p 8080:8080 youtube_transcript_service
```

## Request

```bash
curl -X POST http://127.0.0.1:8080/transcript \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://www.youtube.com/watch?v=dQw4w9WgXcQ","language":"en"}'
```
