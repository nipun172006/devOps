from app.app import create_app


def test_health_and_readiness_endpoints() -> None:
    client = create_app().test_client()

    assert client.get("/healthz").status_code == 200
    assert client.get("/healthz").get_json() == {"status": "ok"}
    assert client.get("/readyz").status_code == 200
    assert client.get("/readyz").get_json() == {"status": "ready"}


def test_metrics_include_real_request_series() -> None:
    client = create_app().test_client()
    client.get("/")

    response = client.get("/metrics")

    assert response.status_code == 200
    body = response.get_data(as_text=True)
    assert "module19_http_requests_total" in body
    assert 'path="/"' in body


def test_index_identifies_the_service() -> None:
    response = create_app().test_client().get("/")

    assert response.get_json()["service"] == "module19-observability-api"
