# kiro-hyprland-impasto — Claude project instructions

## Overview
Config package for the **Kiro Hyprland Impasto edition**: Hyprland with the impasto Quickshell shell
(andreumassanet/impasto, GPL-3.0), vendored at **v0.6.0** (see `UPSTREAM`). Sibling of
[kiro-hyprland-dms](../kiro-hyprland-dms/CLAUDE.md) and [kiro-hyprland-noctalia](../kiro-hyprland-noctalia/CLAUDE.md).
Public, open-core, shipped via `nemesis_repo`. Base of the KiroTux Hyprland Impasto ISO (`kirotux-hypr-impasto`).
Decisions and scope check are in the internal `Kiro-HQ/Kirotux/KIROTUX-HYPRLAND-IMPASTO-RELEASE-PLAN.md` and
`study-of-hyprland-impasto.md`.

## Edition spec (the WM-variable matrix)
- **Compositor:** Hyprland 0.56+ (Lua config). 0.57 checked with `Hyprland --verify-config`.
- **Config:** impasto's modular Lua, kept modular: `etc/skel/.config/kiro-hyprland-impasto/hyprland.lua` requires
  `modules/*.lua`. The session wrapper starts Hyprland with `--config` on it (never `~/.config/hypr/`).
- **Shell:** impasto in `/etc/xdg/quickshell/impasto` (system-wide, read-only), started and reached with
  `qs -p /etc/xdg/quickshell/impasto` (autostart, restart bind, `usr/bin/impasto`). Never set `QS_CONFIG_PATH`: it
  leaks into the systemd user env and would hijack a DMS session's `qs`. The shell is the bar, launcher, lock (PAM
  `login`), notifications and polkit agent. Its state lives in `~/.local/state/quickshell`, and its profiles live in
  `~/.local/share/impasto`.
- **Wallpaper:** awww, driven by the shell. Variety (autostarted) calls `impasto wallpaper set <file>` through
  `set_wallpaper_kiro` (kiro-variety-config), so the palette follows every change.
- **Autostart:** `modules/autostart.lua`: `qs -d`, `awww-daemon`, then Kiro's start (dbus/systemd env,
  xdg-user-dirs, gsettings import, Variety, the archiso-gated Calamares line).
- **Plugins:** `hypr-dynamic-cursors` and `hyprglass` are separate packages (KIRO-PKG-BUILD-3PARTY), loaded from
  `/usr/lib/hyprland-plugins/` by `hyprland.lua` when present. They are not on the AUR and must be rebuilt for every
  Hyprland bump.
- **Default apps:** `modules/programs.lua`: alacritty, Thunar, Firefox, subl, overridden by the premium app's
  `kirotux_apps.lua`.

## Vendored upstream: how to bump
- Commit `103ab24` is the pristine v0.6.0 import. Every Kiro change is a commit after it, so
  `git diff 103ab24..HEAD -- etc/xdg etc/skel usr/bin/impasto` is the patch set.
- To bump:
  1. Copy the new tag's `home/.config/quickshell`, `home/.config/hypr` and `home/.local/bin/impasto` over the tree
     in one "Import impasto vX" commit.
  2. Re-apply the patches below.
  3. Update `UPSTREAM`.
- Never import `home/.local/share/wallpapers`, `system/` or `setup`. The images have no licence, and they would stay
  in the public history.

### Kiro patches (grep anchors)
1. `scripts/theme_manager.py`: `write_alacritty_palette()`, called from `push_terminal_palette()`. The GTK/KDE/Qt
   pushes are upstream's, unchanged: on the KiroTux ISO this is the only desktop.
2. `./setup` hints reworded in `CameraPanel.qml`, `MachinesPanel.qml`, `InputSection.qml`, `WindowsSection.qml`,
   `SessionSection.qml`, together with their keys in `theme/Tr.qml` (English key + Spanish value).
3. `hypr/modules/programs.lua`, `env.lua` (Kiro env, no impasto-cursor), `input.lua` (installer keyboard),
   `autostart.lua` (`qs -p`, no hyprpm block, Kiro start), `keybinds.lua` (Kiro scheme), `windowrules.lua`,
   `hyprland.lua` (plugin loads, `appearance.lua` last); `usr/bin/impasto` (`qs ipc -p`).
4. Profiles: upstream's three replaced by `1-kiro.json` (the Kiro wallpaper). A fresh install takes the first
   profile. **Its `settings.keys` are the real default keybinds**, not `keybinds.lua`'s fallbacks.

## Gotchas
- `hl.exec_cmd` (autostart) runs argv without a shell. Wrap tests and `&&` in `sh -c`. Binds (`hl.dsp.exec_cmd`) do
  have a shell.
- Profiles override `keybinds.lua`. Change default keys in `1-kiro.json` **and** the matching `keybinds.lua`
  fallback, and keep `keybindings.txt` in lockstep.
- Don't add mako/swaync, hyprlock or a polkit agent; the shell owns them.
- Lint: `ruff.toml`/`.codespellrc` skip the vendored tree. After patching an upstream `.py`, run
  `ruff check --no-force-exclude <file>` and make sure the count doesn't go up.
- Test on QEMU (virtio-vga-gl) or metal, not VirtualBox.

## Build / delivery
`~/KIRO-PKG-BUILD-APPS/kiro-hyprland-impasto/build.sh` (`flow-kiro-hyprland-impasto`) → `~/EDU/nemesis_repo`.
Live users exist once the ISO ships: never overwrite `~/.config`, and keep `provides`/`replaces` on renames.
