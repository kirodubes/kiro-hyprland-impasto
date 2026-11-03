-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   E N V                                                                  │
-- │   environment variables                                                  │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- · cursor theme: a vector hyprcursor so shake-to-find (input.lua) magnifies
-- · it cleanly. The shell rebuilds it in the chosen colour; Bibata is the
-- · XCursor fallback. `./setup cursors` fetches both.
-- Kiro: no impasto-cursor here, it is built by upstream's ./setup, which Kiro does not ship.
hl.env("XCURSOR_THEME",    "Bibata-Modern-Classic")

-- · Qt platform theme; the palette push writes qt6ct's colour scheme.
-- · Quickshell draws from its own Theme.qml and is unaffected.
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Kiro: the shell ships system-wide as /etc/xdg/quickshell/impasto. Every bare `qs` in this
-- session (the shell itself, `qs ipc call`, the impasto command, Variety) reaches it through
-- this variable, so no other session's Quickshell config is touched.
hl.env("QS_CONFIG_PATH", "/etc/xdg/quickshell/impasto")

-- Kiro: Wayland across toolkits and the session name for the portals, as the other Kiro
-- Hyprland editions. WLR_* keep VMs (VirtualBox/VMware/QEMU) from black-screening.
hl.env("GDK_BACKEND",                  "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",              "wayland;xcb")
hl.env("MOZ_ENABLE_WAYLAND",           "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("OZONE_PLATFORM",               "wayland")
hl.env("XDG_CURRENT_DESKTOP",          "Hyprland")
hl.env("XDG_SESSION_DESKTOP",          "Hyprland")
hl.env("XDG_SESSION_TYPE",             "wayland")
hl.env("WLR_NO_HARDWARE_CURSORS",      "1")
hl.env("WLR_RENDERER_ALLOW_SOFTWARE",  "1")

-- · user folders from user-dirs.dirs, since their names are localised. Parsed
-- · directly because `xdg-user-dir` returns $HOME for an unset key.
local home   = os.getenv("HOME")
local config = os.getenv("XDG_CONFIG_HOME") or home .. "/.config"

local function user_dirs()
    local dirs = {}
    local file = io.open(config .. "/user-dirs.dirs")
    if not file then return dirs end
    for line in file:lines() do
        local name, value = line:match('^XDG_(%u+)_DIR="(.*)"$')
        if name then
            local rest = value:match("^%$HOME(.*)$")
            dirs[name] = (rest and home .. rest or value):gsub("\\(.)", "%1")
        end
    end
    file:close()
    return dirs
end

-- · capture folders, shared by the shell and hyprshot. XDG_SCREENSHOTS_DIR,
-- · XDG_SCREENCASTS_DIR and XDG_CAMERA_DIR in user-dirs.dirs override the
-- · defaults; the camera's is where GNOME's camera puts its photos.
local dirs       = user_dirs()
local captures   = dirs.SCREENSHOTS or (dirs.PICTURES or home) .. "/Screenshots"
local recordings = dirs.SCREENCASTS or (dirs.VIDEOS or home) .. "/Screencasts"
local camera     = dirs.CAMERA or (dirs.PICTURES or home) .. "/Camera"
hl.env("IMPASTO_CAPTURES",   captures)
hl.env("HYPRSHOT_DIR",       captures)
hl.env("IMPASTO_RECORDINGS", recordings)
hl.env("IMPASTO_CAMERA",     camera)
