from typing import Iterable, List, Optional
from urllib.parse import parse_qs, urlparse

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api._errors import (
    CouldNotRetrieveTranscript,
    NoTranscriptFound,
    TranscriptsDisabled,
    VideoUnavailable,
)


class TranscriptRequest(BaseModel):
    url: str = Field(..., min_length=1)
    language: Optional[str] = None


class TranscriptSegment(BaseModel):
    start: float
    duration: float
    text: str


class TranscriptResponse(BaseModel):
    text: str
    source: str = "captions"
    language: str
    segments: List[TranscriptSegment]


app = FastAPI(title="YouTube Transcript Service")


def parse_video_id(url: str) -> Optional[str]:
    parsed = urlparse(url.strip())
    if not parsed.netloc:
        return None

    host = parsed.netloc.lower()
    if host in {"youtu.be", "www.youtu.be"}:
        return parsed.path.lstrip("/") or None

    if "youtube.com" in host:
        if parsed.path == "/watch":
            return parse_qs(parsed.query).get("v", [None])[0]
        if parsed.path.startswith("/embed/"):
            return parsed.path.split("/", 2)[2] or None
        if parsed.path.startswith("/shorts/"):
            return parsed.path.split("/", 2)[2] or None

    return None


def select_caption_transcript(transcripts, language: Optional[str]):
    if language:
        try:
            return transcripts.find_manually_created_transcript([language])
        except NoTranscriptFound:
            try:
                return transcripts.find_generated_transcript([language])
            except NoTranscriptFound:
                return None

    try:
        return transcripts.find_manually_created_transcript(["en"])
    except NoTranscriptFound:
        try:
            return transcripts.find_generated_transcript(["en"])
        except NoTranscriptFound:
            manual = [
                transcript for transcript in transcripts if not transcript.is_generated
            ]
            if manual:
                return manual[0]

            generated = [
                transcript for transcript in transcripts if transcript.is_generated
            ]
            return generated[0] if generated else None


def normalize_segment_text(text: str) -> str:
    return " ".join(text.split()).strip()


def segment_value(segment, key: str):
    if isinstance(segment, dict):
        return segment.get(key)
    return getattr(segment, key, None)


def build_segments(raw_segments: Iterable[dict]) -> List[TranscriptSegment]:
    return [
        TranscriptSegment(
            start=float(segment_value(segment, "start") or 0.0),
            duration=float(segment_value(segment, "duration") or 0.0),
            text=normalize_segment_text(segment_value(segment, "text") or ""),
        )
        for segment in raw_segments
    ]


def join_text(segments: Iterable[TranscriptSegment]) -> str:
    return " ".join(segment.text for segment in segments if segment.text).strip()


def fetch_caption_segments(video_id: str, language: Optional[str]):
    transcripts = YouTubeTranscriptApi().list(video_id)
    transcript = select_caption_transcript(transcripts, language)
    if transcript is None:
        return None, None
    return transcript.fetch(), transcript.language_code


@app.post("/transcript", response_model=TranscriptResponse)
def transcript(payload: TranscriptRequest) -> TranscriptResponse:
    video_id = parse_video_id(payload.url)
    if not video_id:
        raise HTTPException(
            status_code=400,
            detail="Invalid YouTube URL. Provide a full watch, embed, shorts, or youtu.be URL.",
        )

    try:
        raw_segments, language = fetch_caption_segments(video_id, payload.language)
    except VideoUnavailable as exc:
        raise HTTPException(
            status_code=404, detail="Video unavailable or private."
        ) from exc
    except TranscriptsDisabled as exc:
        raise HTTPException(
            status_code=404, detail="Captions are disabled for this video."
        ) from exc
    except NoTranscriptFound as exc:
        raise HTTPException(
            status_code=404,
            detail="No captions available for the requested language.",
        ) from exc
    except CouldNotRetrieveTranscript as exc:
        raise HTTPException(
            status_code=502,
            detail="Unable to retrieve captions from YouTube.",
        ) from exc

    if raw_segments is None or language is None:
        raise HTTPException(
            status_code=404,
            detail="No captions available for the requested language.",
        )

    segments = build_segments(raw_segments)
    if not segments:
        raise HTTPException(status_code=404, detail="No caption segments found.")

    return TranscriptResponse(
        text=join_text(segments),
        language=language,
        segments=segments,
    )
