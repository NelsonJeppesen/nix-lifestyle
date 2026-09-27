#!/usr/bin/env bash
# make-loop.sh - Re-cut loop.webm, the source clip for the boot splash.
#
# profiles/plymouth.nix takes its frames from loop.webm at build time
# (`frameTimes` picks the moments), so this only has to produce a clean
# clip to choose them from.
#
# Stored at 1440x900 (16:10, matching every panel this repo drives), the
# size plymouth.nix emits its frames at. Higher costs git weight for
# quality that gets thrown away on decode.
set -euo pipefail

usage() {
  cat <<'EOF'
usage: make-loop.sh <url-or-file> [start] [duration]

  start     seek into the source before cutting (default 0)
  duration  seconds to keep (default: the whole source)

Writes loop.webm next to this script. Needs yt-dlp and ffmpeg; on NixOS:
  nix shell nixpkgs#yt-dlp nixpkgs#ffmpeg -c ./make-loop.sh <url>
EOF
}

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  usage
  exit 1
fi

src=$1
start=${2:-0}
duration=${3:-}
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

if [ -f "$src" ]; then
  input=$src
else
  # Cap the download: nothing above 1440p survives the scale below.
  yt-dlp --no-playlist -f "bestvideo[height<=1440]/best" \
    -o "$work/src.%(ext)s" "$src"
  input=$(find "$work" -name 'src.*' -print -quit)
fi

trim=(-ss "$start")
[ -n "$duration" ] && trim+=(-t "$duration")

# Scale by height then centre-crop to width, so 16:9 sources fill a 16:10
# frame instead of being letterboxed into it.
ffmpeg -nostdin -y -loglevel error "${trim[@]}" -i "$input" \
  -vf "scale=-2:900,crop=1440:900" \
  -c:v libvpx-vp9 -crf 32 -b:v 0 -an -row-mt 1 \
  "$here/loop.webm"

printf 'wrote %s (%s)\n' "$here/loop.webm" \
  "$(du -h "$here/loop.webm" | cut -f1)"
printf 'remember: git add it, or the flake cannot see it\n'
