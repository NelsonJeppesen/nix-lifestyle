#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

install -d /usr/local/bin /usr/local/lib64 /etc/ld.so.conf.d
cp -a "$root/dist/bin/." /usr/local/bin/
cp -a "$root/dist/lib64/." /usr/local/lib64/
printf '/usr/local/lib64\n' >/etc/ld.so.conf.d/usr-local-lib64.conf
ldconfig
