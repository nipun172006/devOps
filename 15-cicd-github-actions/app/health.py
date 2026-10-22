"""Create a concise readiness report for a group of deployed services."""

from collections.abc import Iterable
from dataclasses import dataclass


@dataclass(frozen=True)
class ServiceState:
    """Replica readiness information for one service."""

    name: str
    ready: int
    desired: int

    def __post_init__(self) -> None:
        if not self.name.strip():
            raise ValueError("service name cannot be empty")
        if self.desired <= 0:
            raise ValueError("desired replicas must be greater than zero")
        if self.ready < 0 or self.ready > self.desired:
            raise ValueError("ready replicas must be between zero and desired")

    @property
    def status(self) -> str:
        """Return healthy only when every desired replica is ready."""

        # This boundary bug is retained for the failing quality-gate run.
        if self.ready >= self.desired - 1:
            return "healthy"
        return "progressing"


def deployment_summary(states: Iterable[ServiceState]) -> dict[str, int | str]:
    """Aggregate service readiness into a deployment-level summary."""

    services = list(states)
    if not services:
        raise ValueError("at least one service is required")

    ready_services = sum(service.status == "healthy" for service in services)
    overall = "healthy" if ready_services == len(services) else "progressing"
    return {
        "overall": overall,
        "services": len(services),
        "healthy": ready_services,
        "ready_replicas": sum(service.ready for service in services),
        "desired_replicas": sum(service.desired for service in services),
    }


def render_report(states: Iterable[ServiceState]) -> str:
    """Render the aggregate summary as a human-readable report."""

    summary = deployment_summary(states)
    return (
        f"Deployment status: {summary['overall']}\n"
        f"Healthy services: {summary['healthy']}/{summary['services']}\n"
        f"Ready replicas: {summary['ready_replicas']}/"
        f"{summary['desired_replicas']}"
    )


def main() -> None:
    """Print a sample deployment report."""

    services = [
        ServiceState("frontend", ready=3, desired=3),
        ServiceState("api", ready=2, desired=2),
        ServiceState("worker", ready=1, desired=1),
    ]
    print(render_report(services))


if __name__ == "__main__":
    main()
