import json
import os
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

from telethon.errors import SessionPasswordNeededError
from telethon.sync import TelegramClient


def required_env(name):
    value = os.environ.get(name)
    if not value:
        raise RuntimeError(f"Missing {name}")
    return value


def session_path():
    base = os.environ.get("TELEGRAM_SESSION_DIR")
    if not base:
        base = os.path.join(os.path.dirname(__file__), "session")
    os.makedirs(base, exist_ok=True)
    return os.path.join(base, "user")


def login(client, phone):
    if client.is_user_authorized():
        return

    client.send_code_request(phone)
    code = os.environ.get("TELEGRAM_LOGIN_CODE")
    if not code:
        code = input("Enter Telegram login code: ").strip()
    try:
        client.sign_in(phone=phone, code=code)
    except SessionPasswordNeededError:
        password = os.environ.get("TELEGRAM_PASSWORD")
        if not password:
            password = os.environ.get("TELEGRAM_LOGIN_PASSWORD")
        if not password:
            password = input("Enter Telegram 2FA password: ").strip()
        client.sign_in(password=password)


def json_response(handler, status, payload):
    body = json.dumps(payload).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def parse_body(handler):
    length = int(handler.headers.get("Content-Length", "0"))
    if length == 0:
        return {}
    raw = handler.rfile.read(length)
    return json.loads(raw.decode("utf-8"))


def message_to_dict(message):
    return {
        "id": message.id,
        "text": message.message or "",
        "out": message.out,
        "date": message.date.isoformat() if message.date else None,
    }


def build_server(client):
    last_ids = {}

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            parsed = urlparse(self.path)
            if parsed.path != "/updates":
                json_response(self, 404, {"ok": False, "error": "not_found"})
                return

            params = parse_qs(parsed.query)
            peer = params.get("peer", [None])[0]
            limit = int(params.get("limit", ["20"])[0])
            after_id = params.get("after_id", [None])[0]

            if not peer:
                json_response(self, 400, {"ok": False, "error": "peer_required"})
                return

            try:
                entity = client.get_entity(peer)
                messages = client.get_messages(entity, limit=limit)
                items = [
                    message_to_dict(message)
                    for message in reversed(messages)
                    if not message.out
                ]

                if after_id is not None:
                    min_id = int(after_id)
                else:
                    min_id = last_ids.get(peer, 0)

                items = [item for item in items if item["id"] > min_id]

                if items:
                    last_ids[peer] = items[-1]["id"]

                json_response(self, 200, {"ok": True, "result": items})
            except Exception as exc:
                json_response(self, 500, {"ok": False, "error": str(exc)})

        def do_POST(self):
            if self.path != "/send":
                json_response(self, 404, {"ok": False, "error": "not_found"})
                return

            try:
                payload = parse_body(self)
                peer = payload.get("peer")
                text = payload.get("text")

                if not peer or not text:
                    json_response(self, 400, {"ok": False, "error": "peer_text_required"})
                    return

                entity = client.get_entity(peer)
                message = client.send_message(entity, text)
                json_response(
                    self,
                    200,
                    {
                        "ok": True,
                        "result": message_to_dict(message),
                    },
                )
            except Exception as exc:
                json_response(self, 500, {"ok": False, "error": str(exc)})

        def log_message(self, format, *_args):
            return

    return Handler


def main():
    api_id = int(required_env("TELEGRAM_API_ID"))
    api_hash = required_env("TELEGRAM_API_HASH")
    phone = required_env("TELEGRAM_PHONE")
    host = os.environ.get("TELEGRAM_BRIDGE_HOST", "127.0.0.1")
    port = int(os.environ.get("TELEGRAM_BRIDGE_PORT", "8081"))

    client = TelegramClient(session_path(), api_id, api_hash)
    client.connect()
    login(client, phone)

    handler = build_server(client)
    server = HTTPServer((host, port), handler)
    print(f"Telegram bridge listening on http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
