-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   H Y P R L A N D                                                        │
-- │   wayland compositor · entry point                                       │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- Lua config (Hyprland 0.55+); hyprlang is deprecated.
-- https://wiki.hypr.land/Configuring/Start/
--
-- This file only loads the modules in modules/, in order. Hyprland runs each
-- require in its own scope: an error in one module will not break the rest.

-- Kiro: the two plugins come as packages (no hyprpm). Loaded only when installed;
-- Hyprland parses the config again once a plugin is in, and input.lua and look.lua
-- configure them on that pass.
-- A plugin only loads on the exact Hyprland commit it was built against. Right after a
-- Hyprland update, until the plugin packages are rebuilt, loading one shows a "failed to
-- load" banner; so a strict plugin is loaded only when its file holds the running commit,
-- and is skipped quietly otherwise. hyprglass is not strict: its own load guard accepts a
-- Hyprland whose API still fits (it loaded fine on 0.57.1 while built for 0.57.0). The
-- instance signature starts with the running commit; version.h is the fallback.
local function running_commit()
    local commit = (os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or ""):match("^(%x+)_")
    if commit and #commit == 40 then
        return commit
    end
    local header = io.open("/usr/include/hyprland/src/version.h")
    if not header then
        return nil
    end
    local text = header:read("a")
    header:close()
    return text:match('GIT_COMMIT_HASH%s+"(%x+)"')
end

local commit = running_commit()
for _, entry in ipairs({ { "/usr/lib/hyprland-plugins/dynamic-cursors.so", true },
                         { "/usr/lib/hyprland-plugins/hyprglass.so", false } }) do
    local plugin, strict = entry[1], entry[2]
    local file = io.open(plugin, "rb")
    if file then
        local data = strict and commit and file:read("a") or ""
        file:close()
        if not strict or not commit or data:find(commit, 1, true) then
            hl.plugin.load(plugin)
        else
            print("skipped " .. plugin .. ": built for another Hyprland, rebuild pending")
        end
    end
end

require("modules.monitors")
require("modules.autostart")
require("modules.env")
require("modules.look")
require("modules.animations")
require("modules.input")
require("modules.keybinds")
require("modules.windowrules")

-- Kiro: KiroTux Hyprland Premium writes the look you change there to appearance.lua in
-- this folder. Keep these lines last. pcall: a missing or broken file never breaks the session.
local ok, err = pcall(require, "appearance")
if not ok and not tostring(err):find("module 'appearance' not found", 1, true) then
    print("appearance.lua: " .. tostring(err))
end
