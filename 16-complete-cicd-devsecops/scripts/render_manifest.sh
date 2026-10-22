#!/usr/bin/env sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 IMAGE OUTPUT_DIRECTORY" >&2
  exit 2
fi

image=$1
output_directory=$2

mkdir -p "$output_directory"
cp k8s/namespace.yaml "$output_directory/namespace.yaml"
cp k8s/service.yaml "$output_directory/service.yaml"
sed "s|IMAGE_PLACEHOLDER|$image|g" k8s/deployment.yaml > "$output_directory/deployment.yaml"

echo "Rendered Kubernetes manifests with image: $image"
