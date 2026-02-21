#!/usr/bin/env bash
set -euo pipefail

TODO_FILE="${TODO_FILE:-$HOME/drive/obsidian-vault/00 Dashboard/Todos.md}"
CONKY_CFG="$HOME/.config/conky/obsidian_todos.conf"
START_SCRIPT="$HOME/.config/conky/start-obsidian-todos-widget.sh"
POLL_INTERVAL="${POLL_INTERVAL:-1}"

file_signature() {
  if [ -f "$TODO_FILE" ]; then
    stat -c '%Y:%s' "$TODO_FILE" 2>/dev/null || echo 'missing'
  else
    echo 'missing'
  fi
}

last_sig="$(file_signature)"

while true; do
  sleep "$POLL_INTERVAL"
  cur_sig="$(file_signature)"
  if [ "$cur_sig" != "$last_sig" ]; then
    # Restart conky so layout and content are refreshed immediately.
    "$START_SCRIPT" --quiet
    last_sig="$cur_sig"
  fi
done
