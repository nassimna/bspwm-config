#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/2] Restoring bspwm config to $HOME/.config/bspwm"
mkdir -p "$HOME/.config"
rsync -a --delete "$ROOT_DIR/.config/bspwm/" "$HOME/.config/bspwm/"

echo "[2/2] Installing audio profile script to $HOME/.local/bin/audio-profile"
install -Dm755 "$ROOT_DIR/.local/bin/audio-profile" "$HOME/.local/bin/audio-profile"

echo "Restore complete."
