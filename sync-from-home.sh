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
  if [[ -d "$HOME/.config/$dir" ]]; then
    echo "Syncing .config/$dir"
    mkdir -p "$ROOT_DIR/.config/$dir"
    rsync -a --delete "$HOME/.config/$dir/" "$ROOT_DIR/.config/$dir/"
  else
    echo "Skipping missing directory: $HOME/.config/$dir"
  fi
done

if [[ -f "$HOME/.local/bin/audio-profile" ]]; then
  echo "Syncing .local/bin/audio-profile"
  install -Dm755 "$HOME/.local/bin/audio-profile" "$ROOT_DIR/.local/bin/audio-profile"
  # Keep repo copy portable if local script has a hardcoded home path.
  sed -i \
    -e 's|/home/nassimna/.local/share/pipewire-discord-fix|$HOME/.local/share/pipewire-discord-fix|g' \
    -e 's|/home/nassimna/.config/pipewire/pipewire.conf.d/70-virtual-mic-ec.conf|$HOME/.config/pipewire/pipewire.conf.d/70-virtual-mic-ec.conf|g' \
    "$ROOT_DIR/.local/bin/audio-profile"
else
  echo "Skipping missing file: $HOME/.local/bin/audio-profile"
fi

if [[ -d "$HOME/.local/share/pipewire-discord-fix" ]]; then
  echo "Syncing .local/share/pipewire-discord-fix"
  mkdir -p "$ROOT_DIR/.local/share/pipewire-discord-fix"
  rsync -a --delete "$HOME/.local/share/pipewire-discord-fix/" "$ROOT_DIR/.local/share/pipewire-discord-fix/"
else
  echo "Skipping missing directory: $HOME/.local/share/pipewire-discord-fix"
fi

echo "Sync complete"
