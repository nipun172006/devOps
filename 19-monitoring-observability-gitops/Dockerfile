FROM python:3.12.8-slim@sha256:2199a62885a12290dc9c5be3ca0681d367576ab7bf037da120e564723292a2f0

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && addgroup --system app \
    && adduser --system --ingroup app --uid 10001 app

COPY app ./app
USER 10001:10001
EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--access-logfile", "-", "app.app:app"]
