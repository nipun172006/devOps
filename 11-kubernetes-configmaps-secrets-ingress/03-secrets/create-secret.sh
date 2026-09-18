#!/usr/bin/env bash
set -euo pipefail
kubectl create secret generic yatri-db-secret \
  --from-literal=DB_USERNAME=yatri_admin \
  --from-literal=DB_PASSWORD='LabPass-2026!' \
  --dry-run=client -o yaml | kubectl apply -f -
