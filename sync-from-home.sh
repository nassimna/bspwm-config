#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/5] Syncing bspwm config from $HOME/.config/bspwm"
rsync -a --delete "$HOME/.config/bspwm/" "$ROOT_DIR/.config/bspwm/"

echo "[2/5] Syncing audio profile from $HOME/.local/bin/audio-profile"
install -Dm755 "$HOME/.local/bin/audio-profile" "$ROOT_DIR/.local/bin/audio-profile"

echo "[3/5] Syncing PipeWire config from $HOME/.config/pipewire"
rsync -a --delete "$HOME/.config/pipewire/" "$ROOT_DIR/.config/pipewire/"

echo "[4/5] Syncing WirePlumber config from $HOME/.config/wireplumber"
rsync -a --delete "$HOME/.config/wireplumber/" "$ROOT_DIR/.config/wireplumber/"

echo "[5/5] Syncing PipeWire Discord fix data from $HOME/.local/share/pipewire-discord-fix"
rsync -a --delete "$HOME/.local/share/pipewire-discord-fix/" "$ROOT_DIR/.local/share/pipewire-discord-fix/"

echo "Sync complete."
