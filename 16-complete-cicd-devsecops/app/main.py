"""Small API used to demonstrate a gated DevSecOps delivery pipeline."""

from __future__ import annotations

import hashlib
import os
from http import HTTPStatus

from flask import Flask, Response, jsonify, request

APP_NAME = "secure-release-api"
APP_VERSION = "1.0.0"
MAX_CHECKSUM_INPUT = 4096


def create_app() -> Flask:
    """Create the Flask application."""
    app = Flask(__name__)
    app.config["MAX_CONTENT_LENGTH"] = 16 * 1024

    @app.after_request
    def add_security_headers(response: Response) -> Response:
        response.headers["Content-Security-Policy"] = "default-src 'none'"
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "no-referrer"
        return response

    @app.get("/")
    def index():
        return jsonify(
            {
                "service": APP_NAME,
                "message": "DevSecOps gates protect this release",
                "version": APP_VERSION,
            }
        )

    @app.get("/health")
    def health():
        return jsonify({"status": "healthy", "service": APP_NAME})

    @app.get("/api/release")
    def release():
        return jsonify(
            {
                "service": APP_NAME,
                "version": APP_VERSION,
                "revision": os.getenv("SOURCE_REVISION", "local"),
            }
        )

    @app.post("/api/checksum")
    def checksum():
        payload = request.get_json(silent=True)
        if not isinstance(payload, dict) or not isinstance(payload.get("value"), str):
            return jsonify({"error": "value must be a string"}), HTTPStatus.BAD_REQUEST

        value = payload["value"]
        if not value or len(value) > MAX_CHECKSUM_INPUT:
            return (
                jsonify({"error": f"value length must be 1-{MAX_CHECKSUM_INPUT}"}),
                HTTPStatus.BAD_REQUEST,
            )

        digest = hashlib.sha256(value.encode("utf-8")).hexdigest()
        return jsonify({"algorithm": "sha256", "digest": digest})

    @app.errorhandler(HTTPStatus.NOT_FOUND)
    def not_found(_error):
        return jsonify({"error": "route not found"}), HTTPStatus.NOT_FOUND

    return app


app = create_app()
