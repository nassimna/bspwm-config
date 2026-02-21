#!/usr/bin/env bash
set -euo pipefail

QUIET="${1:-}"
WATCH_SCRIPT="$HOME/.config/conky/obsidian_todos_watch.sh"

if ! command -v conky >/dev/null 2>&1; then
  if [ "$QUIET" != "--quiet" ]; then
    echo 'Conky is not installed. Install it first (Arch: sudo pacman -S conky).'
  fi
  exit 0
fi

pkill -f "conky -c $HOME/.config/conky/obsidian_todos.conf" >/dev/null 2>&1 || true
nohup conky -c "$HOME/.config/conky/obsidian_todos.conf" >/dev/null 2>&1 &

# Ensure a single background watcher keeps the widget in sync with Todo file changes.
if ! pgrep -f "$WATCH_SCRIPT" >/dev/null 2>&1; then
  nohup "$WATCH_SCRIPT" >/dev/null 2>&1 &
fi
