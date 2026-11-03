#!/bin/sh
#####################################################################
# Author    : Erik Dubois
# Website   : https://kiroproject.be
#####################################################################
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
# Purpose:
#   At login, give a user without an Alacritty config a small one that
#   imports impasto's palette (~/.config/alacritty/impasto-theme.toml), so the
#   terminals follow the wallpaper's colours.
# Why:
#   impasto's palette push rewrites impasto-theme.toml on every wallpaper change, but
#   Alacritty only reads it when its config imports it, and this edition
#   starts without one. Alacritty watches imported files, so open
#   terminals recolour live. An existing alacritty.toml (yours or
#   kiro-dot-files') is never edited.
#####################################################################

config="$HOME/.config/alacritty/alacritty.toml"

[ -e "$config" ] && exit 0
mkdir -p "${config%/*}"
cat > "$config" <<'EOF'
# Created at login by kiro-hyprland-impasto: the terminal takes the wallpaper's colours from impasto,
# which rewrites impasto-theme.toml on every wallpaper change. Add your own settings below.
[general]
import = ["~/.config/alacritty/impasto-theme.toml"]
EOF
