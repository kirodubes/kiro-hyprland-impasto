-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   P R O G R A M S                                                        │
-- │   default applications · consumed by other modules                       │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- Single place declaring which program does what. To use it:
--     local apps = require("modules.programs")

-- Kiro: the Kiro default apps (alacritty, Thunar, Firefox, Sublime Text). Apps picked in KiroTux
-- Hyprland Premium (kirotux_apps.lua in this folder) win over them, as on the other Kiro editions.
local apps = {
    terminal     = "alacritty",
    file_manager = "thunar",
    browser      = "firefox",
    editor       = "subl",
}

local ok, picked = pcall(require, "kirotux_apps")
if ok and type(picked) == "table" then
    apps.terminal     = picked.terminal or apps.terminal
    apps.file_manager = picked.files or apps.file_manager
    apps.browser      = picked.browser or apps.browser
    apps.editor       = picked.editor or apps.editor
end

return apps
