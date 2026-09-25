#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if command -v shasum >/dev/null 2>&1; then
  hash_file() { shasum -a 256 "$1" | awk '{print $1}'; }
elif command -v sha256sum >/dev/null 2>&1; then
  hash_file() { sha256sum "$1" | awk '{print $1}'; }
else
  echo "error: need shasum or sha256sum to verify frozen schemas" >&2
  exit 1
fi

FROZEN="
schemas/transport/wss-binary-audio-frames-v1.json 5f8dd2c2c83b8e645eb5f41dfa61f6349c304361c54429631ad37e640617abff
"

status=0
while read -r path expected; do
  if [[ -z "$path" ]]; then
    continue
  fi
  if [[ ! -f "$path" ]]; then
    echo "error: frozen artifact is missing: $path" >&2
    status=1
    continue
  fi
  got="$(hash_file "$path")"
  if [[ "$got" != "$expected" ]]; then
    echo "error: $path is frozen by sha256 and its bytes changed." >&2
    echo "  got  $got" >&2
    echo "  want $expected" >&2
    echo "  Refreshing the digest is the deliberate act this gate exists to force." >&2
    echo "  Do it in the same commit as the change, and say why in the commit body." >&2
    status=1
  else
    echo "ok: $path $got"
  fi
done <<< "$FROZEN"

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

echo "Frozen schema artifacts match their pinned digests."
