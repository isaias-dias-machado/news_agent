FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY bridge.py /app/bridge.py

ENV TELEGRAM_BRIDGE_HOST=0.0.0.0
ENV TELEGRAM_BRIDGE_PORT=8081

CMD ["python", "/app/bridge.py"]
