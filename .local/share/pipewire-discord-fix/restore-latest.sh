#!/usr/bin/env bash
set -euo pipefail
BASE="$HOME/.local/share/pipewire-discord-fix"
LATEST="$(find "$BASE/backups" -mindepth 1 -maxdepth 1 -type d | sort | tail -n1)"
if [[ -z "$LATEST" ]]; then
  echo "No backup found under $BASE/backups" >&2
  exit 1
fi
exec "$LATEST/restore.sh"
