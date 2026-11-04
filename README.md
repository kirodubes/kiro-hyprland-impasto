# kiro-hyprland-impasto

The **Kiro Hyprland Impasto** edition: Hyprland with the [impasto](https://github.com/andreumassanet/impasto) shell,
packaged for Kiro. It ships as the `kiro-hyprland-impasto` package from Kiro's `nemesis_repo`.

impasto is a Quickshell shell by Andreu Massanet. The bar centres on one black "island" that turns into the control
centre, the launcher, the overview and your notifications. Under the windows there's a desk of widgets, notes,
tasks and small games. The colours of the bar, the widgets, the terminal and the system monitor are taken from the
wallpaper. Change the wallpaper (by hand or through Variety) and they all follow.

This package is **modified from impasto v0.6.0** (GPL-3.0). See [What Kiro changes](#what-kiro-changes).

## What it ships

| Path | What |
|---|---|
| `/etc/xdg/quickshell/impasto/` | the impasto shell (QML + Python backends), started with `qs` |
| `/etc/skel/.config/kiro-hyprland-impasto/` | this edition's Hyprland Lua config (`hyprland.lua` + `modules/`), wallpaper, scripts |
| `/etc/skel/.local/share/impasto/` | the Kiro profile and the palette board |
| `/usr/bin/impasto` | impasto's command line (`impasto wallpaper set <file>`, `impasto status`, …) |
| `/usr/bin/kiro-hyprland-impasto-session` | the session entry point: uwsm + Hyprland on this edition's config |
| `/usr/share/wayland-sessions/kiro-hyprland-impasto.desktop` | "Kiro Hyprland Impasto" in the login screen |
| `/usr/share/kiro/kiro-hyprland-impasto/` | a pristine copy of the config, to reset to |

It installs next to the other Kiro Hyprland editions. Each one has its own config folder and session, so you pick
one at the login screen.

## Install

```bash
sudo pacman -S kiro-hyprland-impasto
```

Log out, pick **Kiro Hyprland Impasto** in the login screen and log in. A user that existed before the install gets
the config from `/etc/skel` through `kiro-skell`.

Optional extras: `hypr-dynamic-cursors` (shake the pointer to find it), `hyprglass` (glass behind windows),
`variety` (rotating wallpapers), `power-profiles-daemon`, `satty`, `tesseract`, `wf-recorder`, `mpvpaper`, `btop`,
`cava`, `quickemu`.

## What Kiro changes

- Kiro's default apps: alacritty, Thunar, Firefox, Sublime Text.
- Kiro's wallpapers instead of upstream's pictures: the default is `kiro-impasto.jpg`, the Kiro valley repainted in
  thick impasto strokes; the flat original `kiro.jpg` is there too. Both are in `~/.local/share/wallpapers`.
- No `./setup` and no system files. Upstream's own login screen, boot splash and face unlock are not included.
- The shell is installed system-wide, so package updates reach every user.
- Wallpaper colours are applied to GTK apps (Thunar included) and Qt apps too. That's meant for the KiroTux ISO,
  where this is the only desktop. If you install it next to XFCE or Plasma, those desktops see the colours as well.
- The two Hyprland plugins come as packages instead of being built with `hyprpm`.

The full list is in [CLAUDE.md](CLAUDE.md).

## Credits

impasto is © Andreu Massanet, GPL-3.0: <https://github.com/andreumassanet/impasto>. The GrapeNuts font is under the
SIL Open Font License (`/usr/share/fonts/kiro-hyprland-impasto/GrapeNuts-OFL.txt`).

<!-- KIRO-FUNDING-FOOTER:START — managed by Kiro-HQ/cascade-readme-footer.sh -->
## Help fund Kiro

Everything I build here stays free and open — always. If Kiro or any of these
tools have ever saved you time or taught you something, a small monthly
contribution helps keep the work going. Donations target break-even, nothing
more — the core always stays free for everyone.

- GitHub Sponsors: https://github.com/sponsors/erikdubois
- Patreon: https://www.patreon.com/c/kiroproject
- YouTube memberships: https://www.youtube.com/@ErikDubois/join
- Ko-fi: https://ko-fi.com/erikdubois
- PayPal: https://www.paypal.me/erikdubois
<!-- KIRO-FUNDING-FOOTER:END -->
