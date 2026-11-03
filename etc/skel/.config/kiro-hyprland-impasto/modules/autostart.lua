-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   A U T O S T A R T                                                      │
-- │   processes launched with the session                                    │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Quickshell owns org.freedesktop.Notifications, so no separate notification
-- daemon runs: only one process can hold that bus name.
hl.on("hyprland.start", function()
    hl.exec_cmd("qs -d")        -- · bar and notifications (quickshell)
    hl.exec_cmd("awww-daemon")  -- · wallpaper
end)

-- · Kiro session start (as the other Kiro Hyprland editions)
--
-- hl.exec_cmd execs argv directly, without a shell: anything with a test, `&&`
-- or `$VAR` is wrapped in `sh -c`.
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QS_CONFIG_PATH")
    hl.exec_cmd("xdg-user-dirs-update")
    hl.exec_cmd("~/.config/kiro-hyprland-impasto/scripts/import-gsettings.sh")
    hl.exec_cmd("~/.config/kiro-hyprland-impasto/scripts/alacritty-colours.sh")
    hl.exec_cmd("variety")
    -- Live ISO only: start the installer. kiro_final strips this line on install.
    hl.exec_cmd("sh -c '[ -d /run/archiso/bootmnt ] && calamares_polkit -d -style kvantum'")
end)

-- · polkit agent
--
-- The shell is the session's agent and asks on the island; it starts the
-- KDE agent itself if it cannot register, so none is started here.
