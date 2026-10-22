#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
build_dir="${module_dir}/build"
package_dir="${build_dir}/deployment-health"
version="$(tr -d '[:space:]' < "${module_dir}/VERSION")"
archive="${build_dir}/deployment-health-${version}.tar.gz"

if [[ "${build_dir}" != "${module_dir}/build" ]]; then
  echo "Refusing to clean an unexpected build directory" >&2
  exit 1
fi

rm -rf "${build_dir}"
mkdir -p "${package_dir}/app"

cp "${module_dir}/app/__init__.py" "${package_dir}/app/"
cp "${module_dir}/app/health.py" "${package_dir}/app/"
cp "${module_dir}/VERSION" "${package_dir}/"

cat > "${package_dir}/BUILD-INFO.txt" <<EOF
Application: deployment-health
Version: ${version}
Source revision: ${GITHUB_SHA:-local-working-tree}
Build status: SUCCESS
EOF

tar -czf "${archive}" -C "${package_dir}" .

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${archive}" > "${build_dir}/SHA256SUMS"
else
  shasum -a 256 "${archive}" > "${build_dir}/SHA256SUMS"
fi

echo "Build completed: ${archive}"
cat "${build_dir}/SHA256SUMS"
tar -tzf "${archive}" | sort
