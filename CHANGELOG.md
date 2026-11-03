# Changelog

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
- The installer (Calamares) floats, centred, at 85% of the screen. Other open windows can no longer squeeze it into
  a narrow tile. That happened on the first ISO test: three windows opened by keys tiled it into 615 pixels on a
  1280×800 screen. Tested live on QEMU first (1088×680, centred under the bar).

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
