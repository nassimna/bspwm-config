#!/usr/bin/env bash
set -euo pipefail

CONKY_CFG="$HOME/.config/conky/obsidian_todos.conf"
START_SCRIPT="$HOME/.config/conky/start-obsidian-todos-widget.sh"
STOP_SCRIPT="$HOME/.config/conky/stop-obsidian-todos-widget.sh"

is_running() {
  pgrep -f "conky -c $CONKY_CFG" >/dev/null 2>&1
}

primary_monitor() {
  local p
  p="$(xrandr --query 2>/dev/null | awk '/ primary / {print $1; exit}')"
  if [ -z "$p" ]; then
    p="$(bspc query -M --names 2>/dev/null | head -n 1 || true)"
  fi
  printf '%s' "$p"
}

action="${1:-status}"

case "$action" in
  status)
    # Show icon only on main monitor. Polybar sets MONITOR per bar instance.
    pm="$(primary_monitor)"
    if [ -n "${MONITOR:-}" ] && [ -n "$pm" ] && [ "$MONITOR" != "$pm" ]; then
      exit 0
    fi
    printf ''
    ;;
  toggle)
    if is_running; then
      "$STOP_SCRIPT"
    else
      "$START_SCRIPT" --quiet
    fi
    ;;
  start|on)
    "$START_SCRIPT" --quiet
    ;;
  stop|off)
    "$STOP_SCRIPT"
    ;;
  *)
    printf 'Usage: %s [status|toggle|start|stop]\n' "$0" >&2
    exit 1
    ;;
esac
