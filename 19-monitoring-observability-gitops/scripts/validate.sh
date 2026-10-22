#!/usr/bin/env bash
set -euo pipefail

python3 -m pytest tests -q
kubectl apply --dry-run=client -f k8s/namespace.yaml
kubectl apply --dry-run=client -f k8s/deployment.yaml
kubectl apply --dry-run=client -f k8s/service.yaml
