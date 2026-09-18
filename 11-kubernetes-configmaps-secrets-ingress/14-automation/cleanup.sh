#!/usr/bin/env bash
set -euo pipefail
kubectl delete ingress yatri-hybrid-ingress --ignore-not-found
kubectl delete deployment yatri-frontend yatri-api yatri-backend yatri-full-backend --ignore-not-found
kubectl delete service yatri-frontend yatri-api --ignore-not-found
kubectl delete configmap yatri-app-config --ignore-not-found
kubectl delete secret yatri-db-secret yatri-tls --ignore-not-found
echo "Lecture 12 cleanup complete"
