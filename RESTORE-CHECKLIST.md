# Restore Checklist

This repo now includes the config paths needed by your active BSPWM setup:

- `.config/bspwm`
- `.config/polybar`
- `.config/conky`
- `.config/autostart`
- `.config/ghostty`
- `.tmux.conf`
- `.config/pipewire`
- `.config/wireplumber`
- `.local/bin/audio-profile`
- `.local/share/pipewire-echo-fix`

## Recommended restore command

```bash
./bootstrap.sh --yes
```

If your target machine uses a different layout, override target paths:

```bash
./bootstrap.sh \
  --config-home "$HOME/.config" \
  --bspwm-dir "$HOME/.config/bspwm" \
  --sxhkd-dir "$HOME/.config/sxhkd"
```

## External files outside this repo

These are referenced by your current config and should exist on the fresh system:

- `$HOME/wallpapers*` (used by `feh` in `autostart.sh`)
- `$HOME/drive/obsidian-vault/00 Dashboard/Todos.md` (Conky todo widget source)
- `/opt/Handy.AppImage` (from `.config/autostart/Handy.desktop`)
- `/usr/local/bin/arcolinux-welcome-app` (from `.config/autostart/arcolinux-welcome-app.desktop`)

## Core command/runtime dependencies

The main workflow expects these commands/services:

- `bspwm`, `bspc`, `sxhkd`
- `polybar`, `rofi`, `feh`, `dex`, `xrandr`, `setxkbmap`
- `picom`, `conky`, `nm-applet`, `xfce4-power-manager`, `numlockx`, `blueberry-tray`
- `pactl`, `rg`, `systemctl` with user services `pipewire`, `pipewire-pulse`, `wireplumber`
- `amixer`, `playerctl`, `xbacklight`, `scrot`, `maim`, `xclip`
- `checkupdates`, `yay`, `sensors`, `python` (polybar modules)

## Validate after restore

Run:

```bash
./check-deps.sh
```

Then start/reload BSPWM and verify:

- Polybar launches on each monitor
- Conky todo widget toggles with `super + n`
- Audio profiles (`audio-profile status|stable|loud|rollback`) work
