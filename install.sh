#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIRS=(
  "bspwm"
  "polybar"
  "conky"
  "autostart"
  "pipewire"
  "wireplumber"
)

for dir in "${CONFIG_DIRS[@]}"; do
  echo "Restoring .config/$dir"
  mkdir -p "$HOME/.config/$dir"
  rsync -a --delete "$ROOT_DIR/.config/$dir/" "$HOME/.config/$dir/"
done

echo "Installing .local/bin/audio-profile"
install -Dm755 "$ROOT_DIR/.local/bin/audio-profile" "$HOME/.local/bin/audio-profile"

echo "Restoring .local/share/pipewire-discord-fix"
mkdir -p "$HOME/.local/share/pipewire-discord-fix"
rsync -a --delete "$ROOT_DIR/.local/share/pipewire-discord-fix/" "$HOME/.local/share/pipewire-discord-fix/"

echo "Restore complete"
