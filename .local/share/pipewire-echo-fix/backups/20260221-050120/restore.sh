#!/usr/bin/env bash
set -euo pipefail
BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

for rel in \
  .config/pipewire \
  .config/wireplumber \
  .config/pulse \
  .local/state/wireplumber
 do
  if [ -e "$BACKUP_DIR/home-snapshot/$rel" ]; then
    rm -rf "$HOME_DIR/$rel"
    mkdir -p "$(dirname "$HOME_DIR/$rel")"
    cp -a "$BACKUP_DIR/home-snapshot/$rel" "$HOME_DIR/$rel"
  else
    rm -rf "$HOME_DIR/$rel"
  fi
done

systemctl --user restart wireplumber pipewire pipewire-pulse

echo "Restored from: $BACKUP_DIR"
