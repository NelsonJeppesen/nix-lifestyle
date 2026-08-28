#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
image=wkhtmltox-0.12.1-al2023-build

docker build --build-arg "JOBS=$(nproc)" -t "$image" "$root"
rm -rf "$root/dist"
mkdir -p "$root/dist"
docker run --rm -v "$root/dist:/output" "$image"

docker run --rm -v "$root/dist:/opt/wkhtmltox:ro" amazonlinux:2023 bash -eu -c '
  cp -a /opt/wkhtmltox/bin/. /usr/local/bin/
  cp -a /opt/wkhtmltox/lib64/. /usr/local/lib64/
  printf "/usr/local/lib64\n" >/etc/ld.so.conf.d/usr-local-lib64.conf
  ldconfig
  wkhtmltopdf --version
  printf "<h1>AL2023 smoke test</h1>" >/tmp/test.html
  wkhtmltopdf /tmp/test.html /tmp/test.pdf
  test -s /tmp/test.pdf
'
