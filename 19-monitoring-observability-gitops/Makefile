PYTHON ?= python3
IMAGE ?= module19-observability:local
NAMESPACE ?= observability-lab
MONITORING_NAMESPACE ?= monitoring
PROMETHEUS_CHART_VERSION ?= 92.11.0
ARGO_CHART_VERSION ?= 10.10.5

.PHONY: test image validate-manifests load deploy status clean

test:
	$(PYTHON) -m pytest tests -q

image:
	docker build -t $(IMAGE) .

validate-manifests:
	kubectl apply --dry-run=client -f k8s/namespace.yaml
	kubectl apply --dry-run=client -f k8s/deployment.yaml
	kubectl apply --dry-run=client -f k8s/service.yaml

load:
	minikube image load $(IMAGE)

deploy:
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

status:
	kubectl get deployment,pods,service -n $(NAMESPACE)

clean:
	kubectl delete namespace $(NAMESPACE) --ignore-not-found
