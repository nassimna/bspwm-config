#!/usr/bin/env bash
set -euo pipefail

pkill -f "conky -c $HOME/.config/conky/obsidian_todos.conf" >/dev/null 2>&1 || true
pkill -f "$HOME/.config/conky/obsidian_todos_watch.sh" >/dev/null 2>&1 || true
