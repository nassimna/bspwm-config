#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/2] Syncing bspwm config from $HOME/.config/bspwm"
rsync -a --delete "$HOME/.config/bspwm/" "$ROOT_DIR/.config/bspwm/"

echo "[2/2] Syncing audio profile from $HOME/.local/bin/audio-profile"
install -Dm755 "$HOME/.local/bin/audio-profile" "$ROOT_DIR/.local/bin/audio-profile"

echo "Sync complete."
