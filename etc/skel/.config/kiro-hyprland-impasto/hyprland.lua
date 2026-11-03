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
-- configure them on that pass. A plugin built for another Hyprland is refused and
-- the session runs without it.
for _, plugin in ipairs({ "/usr/lib/hyprland-plugins/dynamic-cursors.so",
                          "/usr/lib/hyprland-plugins/hyprglass.so" }) do
    local file = io.open(plugin)
    if file then
        file:close()
        hl.plugin.load(plugin)
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
