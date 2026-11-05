# Changelog

## 2026.11.05

### What Changed
- Notifications scale with the screen, so the message is readable: the pop-up on the island and the Notifications
  card (bell in the bar) take 30% of the screen width, never narrower than before (400 / 380 px) and never wider
  than 700 px. On a 1080p screen that is about 576 px.
- A one-time KiroTux Premium note. About two minutes after the first login in this session, one notification says
  that KiroTux Premium exists (a settings app for this desktop plus a tested installer ISO), with a "Have a look"
  button that opens the Ko-fi page. It shows once per user, never on the live ISO, and never when the premium app is
  installed. Applies to existing users too, on the next package update.

### Technical Details
- `usr/bin/kiro-hyprland-impasto-premium-hint` is started by an XDG autostart entry (`OnlyShowIn=Hyprland`), which
  uwsm runs; a skel change would not reach existing users. The script gates on Hyprland running with this
  edition's config (the same pgrep as the mako drop-in), so the DMS and noctalia sessions never see it.
- It waits for `org.freedesktop.Notifications` to have an owner, writes the marker
  `~/.local/state/kiro-hyprland-impasto/premium-hint-shown` before showing (once even if dismissed), then uses
  `notify-send --action --wait`; impasto's notification server supports actions.
- `DynamicIsland.qml` gets a `screenWidth` property (fed `root.width` by `Bar.qml`, the full-screen bar window)
  and `readableWidth(base)` = clamp(30% of it, base, 700). It wraps the notification layer's `toastWidth` and the
  notifications entry of `moduleSize`; the services keep upstream's 400 / `Theme.cardWidth`, so other cards are
  untouched. Replaces the fixed +100 px from earlier today.

### Files Modified
- `usr/bin/kiro-hyprland-impasto-premium-hint` (new)
- `etc/xdg/autostart/kiro-hyprland-impasto-premium-hint.desktop` (new)
- `etc/xdg/quickshell/impasto/bar/widgets/DynamicIsland.qml`, `etc/xdg/quickshell/impasto/bar/Bar.qml`
- `README.md`, `CLAUDE.md`, `CHANGELOG.md`

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
- New default wallpaper `kiro-impasto.jpg`: the Kiro valley repainted as a thick impasto oil painting, to match
  the edition's name. The flat original `kiro.jpg` stays in the wallpapers folder. New installs only: existing
  users keep the wallpaper they have.
- Num Lock is on when the session starts. The login screen turned it on, but Hyprland switched it back off. New
  installs, and existing users after `kiro-skell` (the change is in `modules/input.lua`).
- The launcher no longer hides an app whose menu entry repeats a line. The live ISO's installer was missing from it
  for that reason. Applies to everyone on the next package update.
- Notifications are impasto's again. mako, which comes along with `kiro-wayland-dotfiles`, took over the
  notification service at every login when an app sent a notification before impasto was up; impasto then had no
  history and no do-not-disturb, and pop-ups were plain mako boxes. mako is now kept out of this session only; the
  waybar editions on the same machine keep it. Applies to everyone on the next package update.

### Technical Details
- `scripts/monitors.py` `rule_chunk()` adds `scale = 1` to any lit rule that has no `scale`; `hl.monitor{}` without
  one means `auto`, which overrode `modules/monitors.lua`. Listed as Kiro patch 5 in CLAUDE.md.
- `hyprland.lua` loads dynamic-cursors only when its `.so` contains the running Hyprland commit (the instance
  signature's prefix, with `/usr/include/hyprland/src/version.h` as fallback); otherwise it prints a skip line.
  hyprglass is always loaded: its own load guard accepted 0.57.1 while it was built for 0.57.0. Tested on a test box
  with `hyprctl reload`: no config errors, hyprglass in, dynamic-cursors skipped.
- CLAUDE.md "how to bump" step 4: run the premium app's `run-impasto-contract.sh` and `run-live-hyprland.sh` on the
  QEMU VM after every impasto bump, so a renamed IPC call, panel or key description is caught before release.
- `kiro-impasto.jpg` was made from Kiro's own `kiro.jpg` with ComfyUI on a test box (SDXL base img2img, strength
  0.70, seed 2026, RealESRGAN x4 to 3840x2160, JPEG q90), so it carries no third-party artwork. It sits in `bg/`
  next to `kiro.jpg`, with the same relative symlink in `~/.local/share/wallpapers`, and `1-kiro.json` points to it.
- `scripts/applications.py` reads desktop entries with `strict=False` (Kiro patch 6). Strict `configparser` raised
  `DuplicateOptionError` on `cal-kiro.desktop` (two `Type=Application`) and `read_entry()` dropped it; the last value
  now wins, as in other launchers. Found on a test laptop's live session: the installer was the only rejected entry.
- `modules/input.lua` sets `numlock_by_default = true`, as `kiro-hyprland-dms` does. impasto's Settings never
  writes that key, so nothing overrides it.
- `usr/lib/systemd/user/mako.service.d/kiro-hyprland-impasto.conf`: `ExecCondition` refuses mako while a Hyprland
  of the user runs with `kiro-hyprland-impasto/hyprland.lua`. mako's D-Bus file has `SystemdService=mako.service`,
  so dbus-broker activates it through systemd and the condition applies; quickshell then registers the name (it
  retries whenever the owner leaves). Seen on a test box and a test laptop (`busctl --user status
  org.freedesktop.Notifications` → mako; qs log "Could not register notification server"); with the drop-in, qs
  owns the name and `notify-send` shows in the island.

### Files Modified
- usr/lib/systemd/user/mako.service.d/kiro-hyprland-impasto.conf (new)
- etc/xdg/quickshell/impasto/scripts/monitors.py
- etc/skel/.local/share/impasto/profiles/1-kiro.json
- etc/skel/.config/kiro-hyprland-impasto/hyprland.lua
- etc/skel/.config/kiro-hyprland-impasto/modules/input.lua
- etc/xdg/quickshell/impasto/scripts/applications.py
- etc/skel/.config/kiro-hyprland-impasto/bg/kiro-impasto.jpg (new)
- etc/skel/.local/share/wallpapers/kiro-impasto.jpg (new symlink)
- README.md
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
