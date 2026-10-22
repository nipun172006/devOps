import os
import time

from flask import Flask, Response, jsonify, request
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest


REQUEST_COUNT = Counter(
    "module19_http_requests_total",
    "Total HTTP requests handled by the Module 19 application.",
    ["method", "path", "status"],
)
REQUEST_LATENCY = Histogram(
    "module19_http_request_duration_seconds",
    "HTTP request duration in seconds.",
    ["path"],
)
APP_INFO = Gauge("module19_app_info", "Module 19 application build information.", ["version"])
READINESS = Gauge("module19_readiness", "Whether the application is ready to serve traffic.")


def create_app() -> Flask:
    app = Flask(__name__)
    version = os.getenv("APP_VERSION", "0.1.0")
    APP_INFO.labels(version=version).set(1)
    READINESS.set(1)

    @app.before_request
    def start_timer() -> None:
        request._module19_started_at = time.perf_counter()

    @app.after_request
    def observe_request(response: Response) -> Response:
        started_at = getattr(request, "_module19_started_at", time.perf_counter())
        path = request.path
        REQUEST_COUNT.labels(request.method, path, str(response.status_code)).inc()
        REQUEST_LATENCY.labels(path).observe(time.perf_counter() - started_at)
        return response

    @app.get("/")
    def index() -> tuple[Response, int]:
        return jsonify({"service": "module19-observability-api", "version": version}), 200

    @app.get("/healthz")
    def healthz() -> tuple[Response, int]:
        return jsonify({"status": "ok"}), 200

    @app.get("/readyz")
    def readyz() -> tuple[Response, int]:
        return jsonify({"status": "ready"}), 200

    @app.get("/metrics")
    def metrics() -> Response:
        return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

    return app


app = create_app()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
