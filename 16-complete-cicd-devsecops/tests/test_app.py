from __future__ import annotations

import hashlib

import pytest

from app.main import APP_NAME, APP_VERSION, create_app


@pytest.fixture
def client():
    app = create_app()
    app.config.update(TESTING=True)
    return app.test_client()


def test_index_describes_service(client):
    response = client.get("/")
    assert response.status_code == 200
    assert response.get_json() == {
        "service": APP_NAME,
        "message": "DevSecOps gates protect this release",
        "version": APP_VERSION,
    }


def test_health_is_healthy(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "healthy", "service": APP_NAME}


def test_release_defaults_to_local_revision(client):
    response = client.get("/api/release")
    assert response.get_json()["revision"] == "local"


def test_release_reads_injected_revision(client, monkeypatch):
    monkeypatch.setenv("SOURCE_REVISION", "abc1234")
    response = client.get("/api/release")
    assert response.get_json()["revision"] == "abc1234"


def test_checksum_returns_sha256(client):
    response = client.post("/api/checksum", json={"value": "devsecops"})
    assert response.status_code == 200
    assert response.get_json() == {
        "algorithm": "sha256",
        "digest": hashlib.sha256(b"devsecops").hexdigest(),
    }


@pytest.mark.parametrize("payload", [None, {}, {"value": 42}, {"value": ""}])
def test_checksum_rejects_invalid_payload(client, payload):
    response = client.post("/api/checksum", json=payload)
    assert response.status_code == 400


def test_checksum_rejects_oversized_value(client):
    response = client.post("/api/checksum", json={"value": "x" * 4097})
    assert response.status_code == 400


def test_unknown_route_is_json(client):
    response = client.get("/missing")
    assert response.status_code == 404
    assert response.get_json() == {"error": "route not found"}


def test_security_headers_are_present(client):
    response = client.get("/health")
    assert response.headers["Content-Security-Policy"] == "default-src 'none'"
    assert response.headers["X-Content-Type-Options"] == "nosniff"
    assert response.headers["X-Frame-Options"] == "DENY"
    assert response.headers["Referrer-Policy"] == "no-referrer"
