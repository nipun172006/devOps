import pytest

from app.health import ServiceState, deployment_summary, main, render_report


def test_fully_ready_service_is_healthy():
    service = ServiceState("api", ready=3, desired=3)

    assert service.status == "healthy"


def test_partially_ready_service_is_progressing():
    service = ServiceState("api", ready=2, desired=3)

    assert service.status == "progressing"


def test_zero_ready_service_is_progressing():
    service = ServiceState("worker", ready=0, desired=2)

    assert service.status == "progressing"


@pytest.mark.parametrize(
    ("ready", "desired"),
    [(-1, 2), (3, 2), (0, 0)],
)
def test_invalid_replica_counts_are_rejected(ready, desired):
    with pytest.raises(ValueError):
        ServiceState("api", ready=ready, desired=desired)


def test_empty_service_name_is_rejected():
    with pytest.raises(ValueError, match="name"):
        ServiceState("  ", ready=1, desired=1)


def test_empty_deployment_is_rejected():
    with pytest.raises(ValueError, match="at least one"):
        deployment_summary([])


def test_summary_counts_services_and_replicas():
    summary = deployment_summary(
        [
            ServiceState("frontend", ready=2, desired=2),
            ServiceState("api", ready=1, desired=2),
        ]
    )

    assert summary == {
        "overall": "progressing",
        "services": 2,
        "healthy": 1,
        "ready_replicas": 3,
        "desired_replicas": 4,
    }


def test_report_is_human_readable():
    report = render_report([ServiceState("frontend", ready=2, desired=2)])

    assert "Deployment status: healthy" in report
    assert "Healthy services: 1/1" in report
    assert "Ready replicas: 2/2" in report


def test_sample_application_prints_healthy_report(capsys):
    main()

    assert capsys.readouterr().out == (
        "Deployment status: healthy\n"
        "Healthy services: 3/3\n"
        "Ready replicas: 6/6\n"
    )
