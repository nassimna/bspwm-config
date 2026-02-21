#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGET_HOME="${TARGET_HOME:-$HOME}"
CONFIG_HOME="${CONFIG_HOME:-$TARGET_HOME/.config}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-$TARGET_HOME/.local/bin}"
LOCAL_SHARE_DIR="${LOCAL_SHARE_DIR:-$TARGET_HOME/.local/share}"
BSPWM_DIR="${BSPWM_DIR:-$CONFIG_HOME/bspwm}"
SXHKD_DIR="${SXHKD_DIR:-$CONFIG_HOME/sxhkd}"
CREATE_SXHKD_COMPAT_LINK="${CREATE_SXHKD_COMPAT_LINK:-1}"

CONFIG_DIRS=(
  "polybar"
  "conky"
  "autostart"
  "pipewire"
  "wireplumber"
)

restore_tree() {
  local src="$1"
  local dest="$2"
  mkdir -p "$dest"
  rsync -a --delete "$src/" "$dest/"
}

echo "Restoring .config/bspwm -> $BSPWM_DIR"
restore_tree "$ROOT_DIR/.config/bspwm" "$BSPWM_DIR"

for dir in "${CONFIG_DIRS[@]}"; do
  echo "Restoring .config/$dir -> $CONFIG_HOME/$dir"
  restore_tree "$ROOT_DIR/.config/$dir" "$CONFIG_HOME/$dir"
done

echo "Installing .local/bin/audio-profile -> $LOCAL_BIN_DIR/audio-profile"
install -Dm755 "$ROOT_DIR/.local/bin/audio-profile" "$LOCAL_BIN_DIR/audio-profile"

echo "Restoring .local/share/pipewire-discord-fix -> $LOCAL_SHARE_DIR/pipewire-discord-fix"
restore_tree "$ROOT_DIR/.local/share/pipewire-discord-fix" "$LOCAL_SHARE_DIR/pipewire-discord-fix"

if [[ "$CREATE_SXHKD_COMPAT_LINK" == "1" ]]; then
  mkdir -p "$SXHKD_DIR"
  ln -sfn "$BSPWM_DIR/sxhkd/sxhkdrc" "$SXHKD_DIR/sxhkdrc"
  echo "Created sxhkd compatibility link: $SXHKD_DIR/sxhkdrc -> $BSPWM_DIR/sxhkd/sxhkdrc"
fi

echo "Restore complete"
