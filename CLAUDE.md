# kiro-hyprland-impasto — Claude project instructions

## Overview
Config package for the **Kiro Hyprland Impasto edition**: Hyprland with the impasto Quickshell shell
(andreumassanet/impasto, GPL-3.0), vendored at **v0.6.3** (see `UPSTREAM`). Sibling of
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
- **Premium hint (ADR-025):** `usr/bin/kiro-hyprland-impasto-premium-hint`, started by
  `etc/xdg/autostart/kiro-hyprland-impasto-premium-hint.desktop` (uwsm runs XDG autostart; system-wide so it reaches
  existing users, unlike skel). Once per user, 120 s after login: skipped outside this session (pgrep on the config
  path, like the mako drop-in), on the live ISO, when `kirotux-hyprland-premium` is installed, or when the marker
  `~/.local/state/kiro-hyprland-impasto/premium-hint-shown` exists. The marker is written before it shows.
- **Default apps:** `modules/programs.lua`: alacritty, Thunar, Firefox, subl, overridden by the premium app's
  `kirotux_apps.lua`.

## Vendored upstream: how to bump
- Branch `impasto-upstream` holds only pristine upstream imports: `103ab24` (v0.6.0), `1dec6d5` (v0.6.1), `76d2391` (v0.6.2), `b22d25a` (v0.6.3).
  `main`
  merges it, so `git diff impasto-upstream..main -- etc/xdg etc/skel usr/bin/impasto` is the patch set.
- To bump:
  1. `git worktree add <scratch> impasto-upstream`; in it copy the new tag's `home/.config/quickshell` (rsync
     --delete), `home/.config/hypr/hyprland.lua` + `modules/*.lua`, `home/.local/bin/impasto` and
     `home/.local/share/impasto/profiles/*.json` over the tree; update `UPSTREAM` (the tag's `^{commit}`, not the
     tag object); commit "Import impasto vX (pristine, unmodified)"; remove the worktree.
  2. `git merge --no-ff impasto-upstream` on `main`: git three-way-merges the patches below. Upstream's profiles
     always conflict (deleted here): `git rm` them, and copy any new key lines they gained into `1-kiro.json`.
  3. Check new upstream keys against the Kiro scheme (`keybinds.lua`, `1-kiro.json`, `keybindings.txt`), new
     user-visible `./setup` hints, and new packages in upstream `packages/pacman.txt` (optdepends in the recipe).
  4. Buyers upgrade from the repo, so test the **upgrade** on a real KiroTux Impasto install: ask Erik to boot
     riker or picard with that SSD (the QEMU VM is only a fallback). Run the two tests below first as a baseline,
     `pacman -U` a local build with a test pkgrel (`26.11-12.1`, so the flow's next pkgrel still upgrades), restart
     the shell, run them again. Restart over SSH with Lua syntax (plain `hyprctl dispatch exec ...` fails), after
     exporting `XDG_RUNTIME_DIR` and `HYPRLAND_INSTANCE_SIGNATURE`: `hyprctl dispatch 'hl.dsp.exec_cmd("pkill -x qs;
     sleep 0.5; qs -p /etc/xdg/quickshell/impasto -d")'`. `KHP_APP_DIR` is the app folder
     (`<tree>/usr/share/kirotux-hyprland-premium`), not the tree root. With `KHP_APP_DIR=<tree>` they test the current premium app tree. From the
     premium app's `tests/`:
     `run-impasto-contract.sh` (headless: every IPC call, panel, layout and key description the premium Discover page
     uses) and `run-live-hyprland.sh`. Both 0 FAIL before the flow publishes. A FAIL names what upstream renamed:
     fix `khp_impasto.py` in kirotux-hyprland-premium (private, no remote) alongside the bump.
- Never import `home/.local/share/wallpapers`, `system/` or `setup`. The images have no licence, and they would stay
  in the public history.

### Kiro patches (grep anchors)
1. `scripts/theme_manager.py`: `write_alacritty_palette()`, called from `push_terminal_palette()`. The GTK/KDE/Qt
   pushes are upstream's, unchanged: on the KiroTux ISO this is the only desktop.
2. `./setup` hints reworded in `CameraPanel.qml`, `MachinesPanel.qml`, `InputSection.qml`, `WindowsSection.qml`,
   `SessionSection.qml`, together with their keys in `theme/Tr.qml` (English key + Spanish value).
3. `hypr/modules/programs.lua`, `env.lua` (Kiro env, no impasto-cursor), `input.lua` (installer keyboard),
   `autostart.lua` (`qs -p`, no hyprpm block, Kiro start), `keybinds.lua` (Kiro scheme), `windowrules.lua`,
   `hyprland.lua` (plugin loads with the dynamic-cursors commit guard before upstream's `load()`/`custom/` hook,
   `appearance.lua` last); `usr/bin/impasto` (`qs ipc -p`, and `capture_script()` points at the system-wide shell).
4. Profiles: upstream's three replaced by `1-kiro.json` (wallpaper `bg/kiro-impasto.jpg`, the Kiro valley painted
   with SDXL from Kiro's own `kiro.jpg`; Kiro-HQ `COMFYUI/impasto.py`, seed 2026, strength 0.70). New wallpapers
   must come from our own images or a text-only `--scene`, never from a downloaded picture. A fresh install takes the first
   profile. **Its `settings.keys` are the real default keybinds**, not `keybinds.lua`'s fallbacks.
5. `scripts/monitors.py` `rule_chunk()`: a lit screen saved without a scale gets `scale = 1` (otherwise Hyprland
   uses `auto` and overrides `modules/monitors.lua`).
6. ~~`scripts/applications.py` `strict=False`~~: upstream since v0.6.1 (PR #22), patch dropped.
7. Notification width follows the screen: `bar/widgets/DynamicIsland.qml` `screenWidth` + `readableWidth()`
   (30%, clamped base..700) on the toast and the notifications module; `bar/Bar.qml` passes `screenWidth: root.width`.
8. `services/IdleService.qml`: each `IdleMonitor` is built by a `Variants` (model `[minutes]` or `[]`), since
   Quickshell 0.3.2 never arms a monitor whose timeout changes after creation; `screenIdle` feeds `ScreenTimeService`.
   `1-kiro.json` carries `idleScreen: 15` (XFCE's blank time). Upstream's `keepAwake` (v0.6.1) is folded into the
   `Variants` models, never into `enabled`. Drop the patch once upstream/Quickshell re-arms.
9. `keybinds.lua`: upstream's `SUPER + Z` scratchpad pair is dropped (Kiro has it on `SUPER + U`, same
   `special:scratchpad`, `SUPER + SHIFT + U` = upstream's `scratchpad_send`); the cheatsheet window is on
   `SUPER + ALT + SHIFT + H` (`SUPER + SHIFT + H` = Narrower).
10. `theme/Theme.qml` `apply()` + `isLight()`/`groundTokens`: a light palette (Catppuccin Latte, ground luminance
   > 0.5) leaves the shell's text and grounds alone, so the black island and the desk's widgets keep white text;
   it still takes the accents. GTK/Qt get the whole palette (ThemeService pushes `Palettes` directly).

## Gotchas
- `hl.exec_cmd` (autostart) runs argv without a shell. Wrap tests and `&&` in `sh -c`. Binds (`hl.dsp.exec_cmd`) do
  have a shell.
- Profiles override `keybinds.lua`. Change default keys in `1-kiro.json` **and** the matching `keybinds.lua`
  fallback, and keep `keybindings.txt` in lockstep.
- Don't add mako/swaync, hyprlock or a polkit agent; the shell owns them. mako still arrives through
  `kiro-wayland-dotfiles` and D-Bus-activates on an early notification, so `usr/lib/systemd/user/mako.service.d/`
  refuses it in this session. Check `busctl --user status org.freedesktop.Notifications` shows `qs` on every test.
- Lint: `ruff.toml`/`.codespellrc` skip the vendored tree. After patching an upstream `.py`, run
  `ruff check --no-force-exclude <file>` and make sure the count doesn't go up.
- Test on QEMU (virtio-vga-gl) or metal, not VirtualBox.

## Build / delivery
`~/KIRO-PKG-BUILD-APPS/kiro-hyprland-impasto/build.sh` (`flow-kiro-hyprland-impasto`) → `~/EDU/nemesis_repo`.
Live users exist once the ISO ships: never overwrite `~/.config`, and keep `provides`/`replaces` on renames.
