# Changelog

## 2026.11.04

### What Changed
- Screens default to 100% scale. A screen saved in impasto's Settings → Displays without a scale used to fall back
  to Hyprland's automatic scale (300% in a QEMU VM). A scale picked in Settings still wins. Applies to existing
  users too, on the next package update.
- The dock pins Alacritty, Thunar and Firefox. It pinned kitty and Nautilus (upstream's apps), which the edition
  doesn't ship. New installs only: existing users keep their own dock pins.
- No more "dynamic cursors failed to load" banner right after a Hyprland update. Until the plugin package is
  rebuilt for the new Hyprland, the session starts without shake-to-find; it comes back with the rebuild. New
  installs, and existing users after `kiro-skell` (the change is in `hyprland.lua`).

### Technical Details
- `scripts/monitors.py` `rule_chunk()` adds `scale = 1` to any lit rule that has no `scale`; `hl.monitor{}` without
  one means `auto`, which overrode `modules/monitors.lua`. Listed as Kiro patch 5 in CLAUDE.md.
- `hyprland.lua` loads dynamic-cursors only when its `.so` contains the running Hyprland commit (the instance
  signature's prefix, with `/usr/include/hyprland/src/version.h` as fallback); otherwise it prints a skip line.
  hyprglass is always loaded: its own load guard accepted 0.57.1 while it was built for 0.57.0. Tested on a test box
  with `hyprctl reload`: no config errors, hyprglass in, dynamic-cursors skipped.
- CLAUDE.md "how to bump" step 4: run the premium app's `run-impasto-contract.sh` and `run-live-hyprland.sh` on the
  QEMU VM after every impasto bump, so a renamed IPC call, panel or key description is caught before release.

### Files Modified
- etc/xdg/quickshell/impasto/scripts/monitors.py
- etc/skel/.local/share/impasto/profiles/1-kiro.json
- etc/skel/.config/kiro-hyprland-impasto/hyprland.lua
- CLAUDE.md

## 2026.11.03

### What Changed
- Initial config package for the Kiro Hyprland Impasto edition: Hyprland with the impasto shell (v0.6.0,
  GPL-3.0), in its own `~/.config/kiro-hyprland-impasto/` folder and its own "Kiro Hyprland Impasto" session.
- Kiro default apps, the Kiro wallpaper and one Kiro profile; no `./setup`, no upstream wallpapers, no `system/`
  layer, no hyprpm.
- GTK apps (Thunar) and Qt apps follow the wallpaper's palette, as upstream does. On the KiroTux ISO this is the
  only desktop (a session gate was tried and reverted: impasto only runs in its own session, and gtk.css stays on
  disk after logout, so a gate protects nothing).
- Keys: the Kiro scheme of the other Hyprland editions, with impasto's panels on Super + Alt. Every key can still be
  changed in impasto's Settings → Keys. `keybindings.txt` lists them for `kiro-keybindings` (Super + Ctrl + S).
- The keyboard layout comes from the installer (fallback us,be). Both Ctrl keys switch layout, Caps is Compose, and
  binds follow the active layout.
- Alacritty follows the wallpaper's colours too. Kiro's terminal opacity rules apply.
- The installer (Calamares) stays tiled, as on the other Kiro Hyprland editions. A float rule was added and taken out
  again the same day: Erik prefers it tiled.

### Technical Details
- The first commit is the pristine v0.6.0 import. Every Kiro change is its own commit on top, so
  `git diff 103ab24..HEAD -- etc/xdg etc/skel usr/bin/impasto` is the patch set to re-apply on an upstream bump.
- The shell lives in `/etc/xdg/quickshell/impasto`, and every `qs` call passes `-p` to it: the autostart, the
  restart-shell bind and the `impasto` command (which Variety uses). `QS_CONFIG_PATH` was tried first and dropped,
  because the session exports its environment to systemd and a later DMS login could inherit it.
- Plugins load with `hl.plugin.load()` from `/usr/lib/hyprland-plugins/` when installed; upstream's
  `hl.plugin.* ~= nil` guards keep the config valid without them.
- `ruff.toml` and `.codespellrc` skip the vendored shell tree; patched upstream files are checked to add no ruff
  findings.
- A fresh install takes the first profile, and its `settings.keys` override `keybinds.lua`. `1-kiro.json` is
  therefore generated from `keybinds.lua`: a Lua harness runs the module against a mocked `hl` and lists every bind
  (197 binds, no duplicate chord or description). `keybindings.txt` comes from the same list.
- `theme_manager.py` also writes the terminal palette as `~/.config/alacritty/impasto-theme.toml`;
  `scripts/alacritty-colours.sh` gives a user without an `alacritty.toml` a one-line import of it.

### Files Modified
- All files (new repo).
