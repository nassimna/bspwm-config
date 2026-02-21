#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# BSPWM Config Bootstrap
#
# Purpose:
#   Restore this repo's desktop config onto a fresh machine in a portable way.
#
# What this script does:
#   1) Detects package manager (pacman/apt/dnf/zypper) unless overridden.
#   2) Installs required packages in best-effort mode (or strict mode).
#   3) Restores config files and scripts into target directories.
#   4) Creates an sxhkd compatibility symlink (optional).
#   5) Runs validation checks after restore.
#
# Package categories installed:
#   - WM and UI: bspwm, sxhkd, polybar, rofi, feh, picom, conky
#   - Audio/session: pipewire, wireplumber, alsa-utils, playerctl
#   - Desktop helpers: network applet, power manager, bluetooth tray, dex
#   - Utilities: ripgrep, git, rsync, xrandr/setxkbmap, screenshot tools
#   - Python weather script runtime: python + requests
#
# Notes:
#   - Use '--list-packages' to print the exact package names for your distro.
#   - Use '--skip-deps' if you only want to restore files.
# -----------------------------------------------------------------------------

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INSTALL_DEPS=1
ASSUME_YES=0
STRICT_PACKAGES=0
LIST_PACKAGES_ONLY=0
PACKAGE_MANAGER_OVERRIDE=""
CREATE_SXHKD_COMPAT_LINK=1

TARGET_HOME="${TARGET_HOME:-$HOME}"
CONFIG_HOME="${CONFIG_HOME:-}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-}"
LOCAL_SHARE_DIR="${LOCAL_SHARE_DIR:-}"
BSPWM_DIR="${BSPWM_DIR:-}"
SXHKD_DIR="${SXHKD_DIR:-}"

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [options]

Install dependencies (best-effort), restore configs, and validate setup.

Options:
  --list-packages        Print package list for detected/selected package manager, then exit.
  --package-manager PM   Force package manager: pacman|apt|dnf|zypper.
  --skip-deps            Do not install packages.
  --yes                  Non-interactive package install where supported.
  --strict-packages      Fail if any package cannot be installed.
  --target-home PATH     Target home directory (default: $HOME).
  --config-home PATH     Target config home (default: <target-home>/.config).
  --local-bin PATH       Target local bin (default: <target-home>/.local/bin).
  --local-share PATH     Target local share (default: <target-home>/.local/share).
  --bspwm-dir PATH       Target bspwm config dir (default: <config-home>/bspwm).
  --sxhkd-dir PATH       Target sxhkd config dir (default: <config-home>/sxhkd).
  --no-sxhkd-link        Do not create sxhkd compatibility symlink.
  -h, --help             Show this help.

Examples:
  ./bootstrap.sh --list-packages
  ./bootstrap.sh --package-manager pacman --list-packages
  ./bootstrap.sh --yes
  ./bootstrap.sh --skip-deps
  ./bootstrap.sh --config-home "$HOME/.config" --bspwm-dir "$HOME/.config/bspwm"
EOF
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

# Run a command as root when possible.
run_as_root() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    return 127
  fi
}

# Detect the current system package manager.
detect_package_manager() {
  if command -v pacman >/dev/null 2>&1; then
    echo "pacman"
    return
  fi
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
    return
  fi
  if command -v dnf >/dev/null 2>&1; then
    echo "dnf"
    return
  fi
  if command -v zypper >/dev/null 2>&1; then
    echo "zypper"
    return
  fi
  echo ""
}

# Return the exact package list for a package manager.
get_packages_for_pm() {
  local pm="$1"
  case "$pm" in
    pacman)
      cat <<'EOF'
bspwm
sxhkd
polybar
rofi
feh
dex
picom
conky
network-manager-applet
xfce4-power-manager
numlockx
blueberry
pipewire
pipewire-pulse
wireplumber
alsa-utils
playerctl
xorg-xbacklight
scrot
maim
xclip
pacman-contrib
ripgrep
lm_sensors
python
python-requests
xdotool
xorg-xprop
xorg-xsetroot
xorg-setxkbmap
xorg-xrandr
rsync
git
EOF
      ;;
    apt)
      cat <<'EOF'
bspwm
sxhkd
polybar
rofi
feh
dex
picom
conky-all
network-manager-gnome
xfce4-power-manager
numlockx
blueman
pipewire
pipewire-pulse
wireplumber
alsa-utils
playerctl
xbacklight
scrot
maim
xclip
ripgrep
lm-sensors
python3
python3-requests
xdotool
x11-utils
x11-xserver-utils
x11-xkb-utils
rsync
git
EOF
      ;;
    dnf)
      cat <<'EOF'
bspwm
sxhkd
polybar
rofi
feh
dex-autostart
picom
conky
NetworkManager-applet
xfce4-power-manager
numlockx
blueberry
pipewire
pipewire-pulseaudio
wireplumber
alsa-utils
playerctl
xbacklight
scrot
maim
xclip
ripgrep
lm_sensors
python3
python3-requests
xdotool
xrandr
setxkbmap
rsync
git
EOF
      ;;
    zypper)
      cat <<'EOF'
bspwm
sxhkd
polybar
rofi
feh
dex
picom
conky
NetworkManager-applet
xfce4-power-manager
numlockx
blueberry
pipewire
pipewire-pulseaudio
wireplumber
alsa-utils
playerctl
xbacklight
scrot
maim
xclip
ripgrep
sensors
python3
python3-requests
xdotool
xrandr
setxkbmap
rsync
git
EOF
      ;;
    *)
      return 1
      ;;
  esac
}

print_package_plan() {
  local pm="$1"
  local count
  count="$(get_packages_for_pm "$pm" | sed '/^$/d' | wc -l | tr -d ' ')"
  log "Dependency install plan:"
  log "  package manager: $pm"
  log "  packages ($count):"
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    log "    - $pkg"
  done < <(get_packages_for_pm "$pm")
}

# Install one package based on package manager.
install_package() {
  local pm="$1"
  local pkg="$2"

  case "$pm" in
    pacman)
      if [[ "$ASSUME_YES" -eq 1 ]]; then
        run_as_root pacman -S --needed --noconfirm "$pkg"
      else
        run_as_root pacman -S --needed "$pkg"
      fi
      ;;
    apt)
      if [[ "$ASSUME_YES" -eq 1 ]]; then
        run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
      else
        run_as_root apt-get install "$pkg"
      fi
      ;;
    dnf)
      if [[ "$ASSUME_YES" -eq 1 ]]; then
        run_as_root dnf install -y "$pkg"
      else
        run_as_root dnf install "$pkg"
      fi
      ;;
    zypper)
      if [[ "$ASSUME_YES" -eq 1 ]]; then
        run_as_root zypper --non-interactive install "$pkg"
      else
        run_as_root zypper install "$pkg"
      fi
      ;;
    *)
      return 1
      ;;
  esac
}

# Install dependency list, continue on package-level failures by default.
install_dependencies() {
  local pm="$1"
  local failed=()
  local pkg

  if ! run_as_root true >/dev/null 2>&1; then
    warn "Need root privileges (or sudo) to install packages. Skipping dependency install."
    return 1
  fi

  if [[ "$pm" == "apt" ]]; then
    log "Updating apt package index..."
    run_as_root apt-get update
  fi

  log "Installing dependencies via $pm (best-effort)..."
  while IFS= read -r pkg; do
    [[ -z "$pkg" ]] && continue
    if install_package "$pm" "$pkg" >/dev/null 2>&1; then
      log "[ok]   $pkg"
    else
      log "[warn] failed to install: $pkg"
      failed+=("$pkg")
    fi
  done < <(get_packages_for_pm "$pm")

  if [[ "${#failed[@]}" -gt 0 ]]; then
    warn "Some packages were not installed:"
    printf '  - %s\n' "${failed[@]}" >&2
    if [[ "$STRICT_PACKAGES" -eq 1 ]]; then
      return 1
    fi
  fi

  return 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list-packages)
      LIST_PACKAGES_ONLY=1
      shift
      ;;
    --package-manager)
      PACKAGE_MANAGER_OVERRIDE="$2"
      shift 2
      ;;
    --skip-deps)
      INSTALL_DEPS=0
      shift
      ;;
    --yes)
      ASSUME_YES=1
      shift
      ;;
    --strict-packages)
      STRICT_PACKAGES=1
      shift
      ;;
    --target-home)
      TARGET_HOME="$2"
      shift 2
      ;;
    --config-home)
      CONFIG_HOME="$2"
      shift 2
      ;;
    --local-bin)
      LOCAL_BIN_DIR="$2"
      shift 2
      ;;
    --local-share)
      LOCAL_SHARE_DIR="$2"
      shift 2
      ;;
    --bspwm-dir)
      BSPWM_DIR="$2"
      shift 2
      ;;
    --sxhkd-dir)
      SXHKD_DIR="$2"
      shift 2
      ;;
    --no-sxhkd-link)
      CREATE_SXHKD_COMPAT_LINK=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      warn "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$CONFIG_HOME" ]]; then
  CONFIG_HOME="$TARGET_HOME/.config"
fi
if [[ -z "$LOCAL_BIN_DIR" ]]; then
  LOCAL_BIN_DIR="$TARGET_HOME/.local/bin"
fi
if [[ -z "$LOCAL_SHARE_DIR" ]]; then
  LOCAL_SHARE_DIR="$TARGET_HOME/.local/share"
fi
if [[ -z "$BSPWM_DIR" ]]; then
  BSPWM_DIR="$CONFIG_HOME/bspwm"
fi
if [[ -z "$SXHKD_DIR" ]]; then
  SXHKD_DIR="$CONFIG_HOME/sxhkd"
fi

log "Target paths:"
log "  TARGET_HOME=$TARGET_HOME"
log "  CONFIG_HOME=$CONFIG_HOME"
log "  LOCAL_BIN_DIR=$LOCAL_BIN_DIR"
log "  LOCAL_SHARE_DIR=$LOCAL_SHARE_DIR"
log "  BSPWM_DIR=$BSPWM_DIR"
log "  SXHKD_DIR=$SXHKD_DIR"
log

PM="$PACKAGE_MANAGER_OVERRIDE"
if [[ -z "$PM" ]]; then
  PM="$(detect_package_manager)"
fi

if [[ -n "$PM" ]]; then
  case "$PM" in
    pacman|apt|dnf|zypper)
      ;;
    *)
      warn "Unsupported package manager override: $PM"
      exit 1
      ;;
  esac
fi

if [[ "$LIST_PACKAGES_ONLY" -eq 1 ]]; then
  if [[ -z "$PM" ]]; then
    warn "Could not detect package manager. Use '--package-manager <pm>' to list packages."
    exit 1
  fi
  print_package_plan "$PM"
  exit 0
fi

if [[ "$INSTALL_DEPS" -eq 1 ]]; then
  if [[ -z "$PM" ]]; then
    warn "No supported package manager detected (pacman/apt/dnf/zypper). Skipping dependency install."
  else
    print_package_plan "$PM"
    install_dependencies "$PM" || {
      warn "Dependency installation was incomplete."
      if [[ "$STRICT_PACKAGES" -eq 1 ]]; then
        exit 1
      fi
    }
  fi
fi

log "Applying configuration files..."
TARGET_HOME="$TARGET_HOME" \
CONFIG_HOME="$CONFIG_HOME" \
LOCAL_BIN_DIR="$LOCAL_BIN_DIR" \
LOCAL_SHARE_DIR="$LOCAL_SHARE_DIR" \
BSPWM_DIR="$BSPWM_DIR" \
SXHKD_DIR="$SXHKD_DIR" \
CREATE_SXHKD_COMPAT_LINK="$CREATE_SXHKD_COMPAT_LINK" \
  "$ROOT_DIR/install.sh"

log
log "Running validation checks..."
TARGET_HOME="$TARGET_HOME" \
CONFIG_HOME="$CONFIG_HOME" \
LOCAL_BIN_DIR="$LOCAL_BIN_DIR" \
LOCAL_SHARE_DIR="$LOCAL_SHARE_DIR" \
BSPWM_DIR="$BSPWM_DIR" \
SXHKD_DIR="$SXHKD_DIR" \
  "$ROOT_DIR/check-deps.sh" || true

log
log "Bootstrap complete."
