# bspwm-config

Personal bspwm backup repo for fresh installs.

## Included
- `.config/bspwm`
- `.config/polybar`
- `.config/conky`
- `.config/autostart`
- `.local/bin/audio-profile`
- `.config/pipewire`
- `.config/wireplumber`
- `.local/share/pipewire-echo-fix` (rollback snapshots + restore script)

## Recommended restore (fresh install)
```bash
git clone https://github.com/nassimna/bspwm-config.git bspwm-config
cd bspwm-config
./bootstrap.sh --yes
```

Preview what will be installed first:
```bash
./bootstrap.sh --list-packages
```

`bootstrap.sh` does:
- best-effort dependency install (supports `pacman`, `apt`, `dnf`, `zypper`)
- config restore to configurable target paths
- `sxhkd` compatibility symlink creation (`~/.config/sxhkd/sxhkdrc` -> bspwm sxhkdrc)
- post-restore validation (`check-deps.sh`)

## Custom target paths
Use these flags if your environment uses different locations:
```bash
./bootstrap.sh \
  --config-home "$HOME/.config" \
  --bspwm-dir "$HOME/.config/bspwm" \
  --sxhkd-dir "$HOME/.config/sxhkd"
```

To skip package installation:
```bash
./bootstrap.sh --skip-deps
```

If you only want to copy configs (no dependency install logic), use:
```bash
./install.sh
```

`audio-profile` local file dependencies are included in this repo.

## Runtime requirements
- `pactl` (PulseAudio/PipeWire utilities)
- `rg` (ripgrep)
- `systemctl` (user services: `pipewire`, `pipewire-pulse`, `wireplumber`)

## Full sweep + validation
See `RESTORE-CHECKLIST.md` for:
- what was discovered in the `.config` dependency sweep
- external files still needed outside this repo
- command/runtime requirements

Run a quick validation after restore:
```bash
./check-deps.sh
```

## Update this repo from current machine
```bash
./sync-from-home.sh
git add .
git commit -m "chore: update bspwm config"
```
