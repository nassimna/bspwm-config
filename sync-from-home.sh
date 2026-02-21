#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SOURCE_HOME="${SOURCE_HOME:-$HOME}"
SOURCE_CONFIG_HOME="${SOURCE_CONFIG_HOME:-$SOURCE_HOME/.config}"
SOURCE_LOCAL_BIN_DIR="${SOURCE_LOCAL_BIN_DIR:-$SOURCE_HOME/.local/bin}"
SOURCE_LOCAL_SHARE_DIR="${SOURCE_LOCAL_SHARE_DIR:-$SOURCE_HOME/.local/share}"
SOURCE_BSPWM_DIR="${SOURCE_BSPWM_DIR:-$SOURCE_CONFIG_HOME/bspwm}"

CONFIG_DIRS=(
  "polybar"
  "conky"
  "autostart"
  "pipewire"
  "wireplumber"
)

sync_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  rsync -a --delete "$src/" "$dest/"
}

if [[ -d "$SOURCE_BSPWM_DIR" ]]; then
  echo "Syncing .config/bspwm from $SOURCE_BSPWM_DIR"
  sync_tree "$SOURCE_BSPWM_DIR" "$ROOT_DIR/.config/bspwm"
else
  echo "Skipping missing directory: $SOURCE_BSPWM_DIR"
fi

for dir in "${CONFIG_DIRS[@]}"; do
  if [[ -d "$SOURCE_CONFIG_HOME/$dir" ]]; then
    echo "Syncing .config/$dir from $SOURCE_CONFIG_HOME/$dir"
    sync_tree "$SOURCE_CONFIG_HOME/$dir" "$ROOT_DIR/.config/$dir"
  else
    echo "Skipping missing directory: $SOURCE_CONFIG_HOME/$dir"
  fi
done

if [[ -f "$SOURCE_LOCAL_BIN_DIR/audio-profile" ]]; then
  echo "Syncing .local/bin/audio-profile from $SOURCE_LOCAL_BIN_DIR/audio-profile"
  install -Dm755 "$SOURCE_LOCAL_BIN_DIR/audio-profile" "$ROOT_DIR/.local/bin/audio-profile"
  # Keep repo copy portable and normalized.
  sed -i \
    -e 's|pipewire-discord-fix|pipewire-echo-fix|g' \
    -e 's|/home/nassimna/.config/pipewire/pipewire.conf.d/70-virtual-mic-ec.conf|$HOME/.config/pipewire/pipewire.conf.d/70-virtual-mic-ec.conf|g' \
    "$ROOT_DIR/.local/bin/audio-profile"
else
  echo "Skipping missing file: $SOURCE_LOCAL_BIN_DIR/audio-profile"
fi

if [[ -d "$SOURCE_LOCAL_SHARE_DIR/pipewire-echo-fix" ]]; then
  echo "Syncing .local/share/pipewire-echo-fix from $SOURCE_LOCAL_SHARE_DIR/pipewire-echo-fix"
  sync_tree "$SOURCE_LOCAL_SHARE_DIR/pipewire-echo-fix" "$ROOT_DIR/.local/share/pipewire-echo-fix"
elif [[ -d "$SOURCE_LOCAL_SHARE_DIR/pipewire-discord-fix" ]]; then
  echo "Syncing legacy .local/share/pipewire-discord-fix into repo .local/share/pipewire-echo-fix"
  sync_tree "$SOURCE_LOCAL_SHARE_DIR/pipewire-discord-fix" "$ROOT_DIR/.local/share/pipewire-echo-fix"
else
  echo "Skipping missing directories: $SOURCE_LOCAL_SHARE_DIR/pipewire-echo-fix and $SOURCE_LOCAL_SHARE_DIR/pipewire-discord-fix"
fi

# Normalize legacy naming inside synced scripts.
if [[ -f "$ROOT_DIR/.local/share/pipewire-echo-fix/restore-latest.sh" ]]; then
  sed -i 's|pipewire-discord-fix|pipewire-echo-fix|g' "$ROOT_DIR/.local/share/pipewire-echo-fix/restore-latest.sh"
fi

echo "Sync complete"
