# Changelog

## 2026.11.03

### What Changed
- Initial config package for the Kiro Hyprland Impasto edition: Hyprland with the impasto shell (v0.6.0,
  GPL-3.0), in its own `~/.config/kiro-hyprland-impasto/` folder and its own "Kiro Hyprland Impasto" session.
- Kiro default apps, the Kiro wallpaper and one Kiro profile; no `./setup`, no upstream wallpapers, no `system/`
  layer, no hyprpm.
- The GTK, KDE and Qt colours follow the wallpaper only inside this session.
- Keys: the Kiro scheme of the other Hyprland editions, with impasto's panels on Super + Alt. Every key can still be
  changed in impasto's Settings → Keys. `keybindings.txt` lists them for `kiro-keybindings` (Super + Ctrl + S).
- The keyboard layout comes from the installer (fallback us,be). Both Ctrl keys switch layout, Caps is Compose, and
  binds follow the active layout.
- Alacritty follows the wallpaper's colours too. Kiro's terminal opacity rules apply.

### Technical Details
- The first commit is the pristine v0.6.0 import. Every Kiro change is its own commit on top, so
  `git diff 103ab24..HEAD -- etc/xdg etc/skel usr/bin/impasto` is the patch set to re-apply on an upstream bump.
- The shell lives in `/etc/xdg/quickshell/impasto`. `QS_CONFIG_PATH` is set in `modules/env.lua`, so every bare
  `qs` call in the session (the shell, `qs ipc`, the `impasto` command, Variety) reaches it without patching.
- `theme_manager.py` writes `gtk.css`, `kdeglobals` and `qt6ct` only when `DESKTOP_SESSION` ends in
  `kiro-hyprland-impasto`.
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
