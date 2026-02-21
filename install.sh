#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/5] Restoring bspwm config to $HOME/.config/bspwm"
mkdir -p "$HOME/.config"
rsync -a --delete "$ROOT_DIR/.config/bspwm/" "$HOME/.config/bspwm/"

echo "[2/5] Installing audio profile script to $HOME/.local/bin/audio-profile"
install -Dm755 "$ROOT_DIR/.local/bin/audio-profile" "$HOME/.local/bin/audio-profile"

echo "[3/5] Restoring PipeWire config to $HOME/.config/pipewire"
mkdir -p "$HOME/.config/pipewire"
rsync -a "$ROOT_DIR/.config/pipewire/" "$HOME/.config/pipewire/"

echo "[4/5] Restoring WirePlumber config to $HOME/.config/wireplumber"
mkdir -p "$HOME/.config/wireplumber"
rsync -a "$ROOT_DIR/.config/wireplumber/" "$HOME/.config/wireplumber/"

echo "[5/5] Restoring PipeWire Discord fix data to $HOME/.local/share/pipewire-discord-fix"
mkdir -p "$HOME/.local/share/pipewire-discord-fix"
rsync -a "$ROOT_DIR/.local/share/pipewire-discord-fix/" "$HOME/.local/share/pipewire-discord-fix/"

echo "Restore complete."
