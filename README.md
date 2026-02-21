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
- `.local/share/pipewire-discord-fix` (rollback snapshots + restore script)

## Restore on a fresh install
```bash
git clone <your-remote-url> bspwm-config
cd bspwm-config
./install.sh
```

`audio-profile` runtime dependencies are included in this repo for local files/scripts.

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
