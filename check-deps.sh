#!/usr/bin/env bash
set -euo pipefail

MISSING=0
WARNINGS=0

TARGET_HOME="${TARGET_HOME:-$HOME}"
CONFIG_HOME="${CONFIG_HOME:-$TARGET_HOME/.config}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-$TARGET_HOME/.local/bin}"
LOCAL_SHARE_DIR="${LOCAL_SHARE_DIR:-$TARGET_HOME/.local/share}"
BSPWM_DIR="${BSPWM_DIR:-$CONFIG_HOME/bspwm}"
SXHKD_DIR="${SXHKD_DIR:-$CONFIG_HOME/sxhkd}"

check_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[ok]   command: %s\n' "$cmd"
  else
    printf '[miss] command: %s\n' "$cmd"
    MISSING=1
  fi
}

check_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    printf '[ok]   path:    %s\n' "$path"
  else
    printf '[miss] path:    %s\n' "$path"
    MISSING=1
  fi
}

warn_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '[ok]   command: %s\n' "$cmd"
  else
    printf '[warn] command: %s\n' "$cmd"
    WARNINGS=1
  fi
}

warn_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    printf '[ok]   path:    %s\n' "$path"
  else
    printf '[warn] path:    %s\n' "$path"
    WARNINGS=1
  fi
}

echo '== Command checks =='
for cmd in \
  bspwm bspc sxhkd \
  polybar rofi feh dex xrandr setxkbmap \
  picom conky \
  pactl rg systemctl \
  amixer playerctl scrot maim xclip
  do
  check_cmd "$cmd"
done

echo
echo '== Optional command checks =='
for cmd in \
  nm-applet xfce4-power-manager numlockx blueberry-tray \
  xbacklight \
  checkupdates yay sensors python
  do
  warn_cmd "$cmd"
done

echo
echo '== User service checks =='
if command -v systemctl >/dev/null 2>&1; then
  for svc in pipewire pipewire-pulse wireplumber; do
    if systemctl --user status "$svc" >/dev/null 2>&1; then
      printf '[ok]   service: %s\n' "$svc"
    else
      printf '[warn] service: %s (not running or unavailable in this session)\n' "$svc"
    fi
  done
else
  echo '[miss] systemctl not found; cannot check user services'
  MISSING=1
fi

echo
echo '== File/path checks =='
check_path "$BSPWM_DIR/bspwmrc"
check_path "$SXHKD_DIR/sxhkdrc"
check_path "$CONFIG_HOME/polybar/config.ini"
check_path "$CONFIG_HOME/conky/obsidian_todos.conf"
check_path "$CONFIG_HOME/pipewire/pipewire.conf.d/70-virtual-mic-ec.conf"
check_path "$LOCAL_BIN_DIR/audio-profile"
check_path "$LOCAL_SHARE_DIR/pipewire-discord-fix/restore-latest.sh"
warn_path "$TARGET_HOME/drive/obsidian-vault/00 Dashboard/Todos.md"

if compgen -G "$TARGET_HOME/wallpapers*" >/dev/null; then
  echo "[ok]   path:    $TARGET_HOME/wallpapers*"
else
  echo "[warn] path:    $TARGET_HOME/wallpapers* (no wallpapers matched)"
  WARNINGS=1
fi

warn_path "/opt/Handy.AppImage"
warn_path "/usr/local/bin/arcolinux-welcome-app"

echo
if [[ "$MISSING" -eq 0 ]]; then
  if [[ "$WARNINGS" -eq 0 ]]; then
    echo 'All required checks passed.'
  else
    echo 'Required checks passed with warnings.'
  fi
else
  echo 'Some required checks are missing.'
  exit 1
fi
