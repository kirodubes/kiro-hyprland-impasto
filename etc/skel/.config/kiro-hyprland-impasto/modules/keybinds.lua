-- ╭──────────────────────────────────────────────────────────────────────────╮
-- │                                                                          │
-- │   K E Y B I N D S                                                        │
-- │   keyboard and mouse bindings                                            │
-- │                                                                          │
-- │   github.com/andreumassanet/impasto                                      │
-- │                                                                          │
-- ╰──────────────────────────────────────────────────────────────────────────╯

-- No bind uses /, ., ' or `: they are shifted or dead keys on a Spanish layout.

local apps    = require("modules.programs")
local mainMod = "SUPER"

-- Kiro: the Kiro scheme wins every chord it uses on the other Kiro Hyprland editions;
-- impasto's panels sit on SUPER + ALT. Profiles (Settings → Keys) carry the same table.
local logout      = "archlinux-logout"
local keybindings = "kiro-keybindings"
local function run(cmd) return hl.dsp.exec_cmd(cmd) end


-- ── PROFILE KEYS ────────────────────────────────────────────────────────────

-- The shell writes the active profile's bindings to keys.tsv
-- (description<TAB>combination, empty = unbound) and reloads Hyprland when
-- they change. Descriptions are the keys, so renaming one drops its binding
-- from every profile. The combinations below are the fallback.
local function profile_keys()
    local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
    local keys  = {}
    local file  = io.open(state .. "/quickshell/keys.tsv")
    if not file then
        return keys
    end
    for line in file:lines() do
        local description, combination = line:match("^([^#\t][^\t]*)\t(.*)$")
        if description then
            keys[description] = combination
        end
    end
    file:close()
    return keys
end

local keys = profile_keys()

-- `hl.bind`, on the profile's combination for this description.
local function bind(combination, action, options)
    local chosen = keys[options.description]
    if chosen == nil then
        chosen = combination
    end
    if chosen ~= "" then
        hl.bind(chosen, action, options)
    end
end


-- ── BINDS ───────────────────────────────────────────────────────────────────

hl.config({
    binds = {
        workspace_back_and_forth = true,
    },
})


-- ── APPLICATIONS ────────────────────────────────────────────────────────────

bind(mainMod .. " + Return", hl.dsp.exec_cmd(apps.terminal),     { description = "Applications · Open a terminal" })
bind("SUPER + SHIFT + Return",      hl.dsp.exec_cmd(apps.file_manager), { description = "Applications · Open the file manager" })
bind(mainMod .. " + B",      hl.dsp.exec_cmd(apps.browser),      { description = "Applications · Open the browser" })


-- ── WINDOWS ─────────────────────────────────────────────────────────────────

-- · floating size
--
-- A floated window keeps its tiled size, which for a lone window is the whole
-- workspace. Float it at a fraction of the monitor instead, centred.
local FLOAT_FRACTION = 0.6

-- Resize and centre only when going tiled → floating; the state must be read
-- before the toggle.
local function float_centred()
    local window = hl.get_active_window()
    if not window then
        return
    end

    local was_floating = window.floating
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    if was_floating then
        return
    end

    local monitor = hl.get_active_monitor()
    if not monitor then
        return
    end

    -- The monitor reports physical pixels; the dispatcher takes logical ones.
    local scale = monitor.scale or 1
    hl.dispatch(hl.dsp.window.resize({
        x     = math.floor(monitor.width / scale * FLOAT_FRACTION),
        y     = math.floor(monitor.height / scale * FLOAT_FRACTION),
        exact = true,
    }))
    hl.dispatch(hl.dsp.window.center())
end

-- The split is dwindle's. Master turns its stack to the next side instead;
-- scrolling has no split, and the key does nothing there.
local function flip_split()
    local workspace = hl.get_active_workspace()
    local layout = workspace and workspace.tiled_layout
    if layout == "dwindle" then
        hl.dispatch(hl.dsp.layout("togglesplit"))
    elseif layout == "master" then
        hl.dispatch(hl.dsp.layout("orientationnext"))
    end
end

bind(mainMod .. " + Q",           hl.dsp.window.close(), { description = "Windows · Close the focused window" })
bind("SUPER + ALT + Q",   hl.dsp.window.kill(),  { description = "Windows · Kill the focused window" })
bind(mainMod .. " + F",           hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Windows · Full screen" })
bind(mainMod .. " + ALT + F",     hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }),  { description = "Windows · Maximise, keeping the bar" })
bind("SUPER + SHIFT + Space", float_centred,          { description = "Windows · Float or tile the window" })
bind(mainMod .. " + P",           hl.dsp.window.pseudo(), { description = "Windows · Toggle pseudo-tiling" })
bind(mainMod .. " + J",           flip_split,             { description = "Windows · Flip the split direction" })
bind("SUPER + ALT + Space",   hl.dsp.global("quickshell:layout"), { description = "Windows · Cycle the layout" })

-- · move focus
bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }), { description = "Windows · Focus the window left" })
bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }), { description = "Windows · Focus the window right" })
bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }), { description = "Windows · Focus the window up" })
bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }), { description = "Windows · Focus the window down" })

-- · cycle windows
bind("ALT + Tab",         hl.dsp.window.cycle_next(),                 { repeating = true, description = "Windows · Next window" })
bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }), { repeating = true, description = "Windows · Previous window" })

-- · move the window itself
bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }), { description = "Windows · Move the window left" })
bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }), { description = "Windows · Move the window right" })
bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }), { description = "Windows · Move the window up" })
bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }), { description = "Windows · Move the window down" })

-- · drag and resize with the mouse
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Windows · Drag the window" })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Windows · Resize the window" })


-- ── WORKSPACES ──────────────────────────────────────────────────────────────

-- The workspace each screen was showing before the one it shows now.
-- `workspace_back_and_forth` only reaches the plain dispatcher, and the
-- numbers use `on_current_monitor`; Hyprland's own previous is one for the
-- whole desk, which on two screens is the wrong one.
local before  = {}
local showing = {}

-- Seeded, so the first press of the number already showing has somewhere to
-- go back to. At the first parse there may be no monitors yet, and the event
-- below fills it in.
for _, monitor in ipairs(hl.get_monitors() or {}) do
    if monitor.active_workspace then
        showing[monitor.name] = monitor.active_workspace.id
    end
end

hl.on("workspace.active", function(workspace)
    local monitor = workspace and workspace.monitor
    if not monitor then
        return
    end
    local name = monitor.name
    if showing[name] ~= nil and showing[name] ~= workspace.id then
        before[name] = showing[name]
    end
    showing[name] = workspace.id
end)

-- Shared, or each screen with ten of its own: the shell writes the mode and
-- the screens' order to a file, read on every press so a change needs no
-- reload. The screens in order when each has its own, nil when shared.
local function screen_order()
    local state = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
    local file  = io.open(state .. "/quickshell/workspaces")
    if not file then
        return nil
    end
    local lines = {}
    for line in file:lines() do
        if line ~= "" and line:sub(1, 1) ~= "#" then
            lines[#lines + 1] = line
        end
    end
    file:close()
    if lines[1] ~= "screen" then
        return nil
    end
    return { table.unpack(lines, 2) }
end

-- The workspace before this screen's first; 0 when they are shared.
local function screen_base(monitor)
    local order = monitor and screen_order()
    for position, name in ipairs(order or {}) do
        if name == monitor.name then
            return (position - 1) * 10
        end
    end
    return 0
end

-- The number of the workspace already here goes back to the one before it.
local function to_workspace(index)
    return function()
        local monitor = hl.get_active_monitor()
        local active  = hl.get_active_workspace()
        local back    = monitor and before[monitor.name]
        local target  = screen_base(monitor) + index
        if active and active.id == target and back and back ~= target then
            target = back
        end
        hl.dispatch(hl.dsp.focus({ workspace = target, on_current_monitor = true }))
    end
end

-- Into this screen's own ten, or the shared ten.
local function move_to_workspace(index, follow)
    return function()
        local monitor = hl.get_active_monitor()
        hl.dispatch(hl.dsp.window.move({ workspace = screen_base(monitor) + index, follow = follow }))
    end
end

-- · SUPER + [1-9,0] switches; adding SHIFT moves the window there
--
-- Shared, a number brings its workspace to the screen you are on rather than
-- taking you to the screen it is on: `on_current_monitor` swaps the two
-- screens' workspaces where it has to. Per screen, it is this screen's own.
-- Kiro: key codes (code:10 = "1" … code:19 = "0") so the numbers work on qwerty and
-- azerty alike; CTRL moves the window and follows it, SHIFT sends it and stays.
for i = 1, 10 do
    local key = "code:" .. (i + 9)
    bind(mainMod .. " + " .. key,         to_workspace(i),
         { description = "Workspaces · Go to workspace " .. i })
    bind(mainMod .. " + CTRL + " .. key,  move_to_workspace(i, true),
         { description = "Workspaces · Move the window to workspace " .. i })
    bind(mainMod .. " + SHIFT + " .. key, move_to_workspace(i, false),
         { description = "Workspaces · Send the window to workspace " .. i })
end

-- · scroll wheel to cycle through the ones on this screen
bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "m+1" }), { description = "Workspaces · Next workspace" })
bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "m-1" }), { description = "Workspaces · Previous workspace" })


-- ── SCREENS ─────────────────────────────────────────────────────────────────

-- · the keyboard, and the workspace under it, across screens. A window
-- · crosses with the window keys above: with nothing that way, they hand it
-- · to the next screen.

-- The two screens trade what they are showing, and the keyboard goes with the
-- workspace. Moving it instead buries the other screen's workspace behind
-- this one and leaves a new empty one where you were. The direction is
-- resolved by moving the keyboard first: nothing that way leaves it where it
-- was and changes nothing. With ten workspaces each, the windows trade and
-- the workspaces stay, so every screen keeps its own numbers.
local function trade_workspace(direction)
    return function()
        local here = hl.get_active_monitor()
        if not here then
            return
        end

        hl.dispatch(hl.dsp.focus({ monitor = direction }))

        local there = hl.get_active_monitor()
        if not there or there.name == here.name then
            return
        end

        if not screen_order() then
            hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = here.name, monitor2 = there.name }))
            return
        end

        local from, to = here.active_workspace, there.active_workspace
        if not from or not to then
            return
        end
        local leaving  = hl.get_workspace_windows(from.id) or {}
        local arriving = hl.get_workspace_windows(to.id) or {}
        for _, window in ipairs(leaving) do
            hl.dispatch(hl.dsp.window.move({ workspace = to.id, window = "address:" .. window.address, follow = false }))
        end
        for _, window in ipairs(arriving) do
            hl.dispatch(hl.dsp.window.move({ workspace = from.id, window = "address:" .. window.address, follow = false }))
        end
    end
end

bind(mainMod .. " + ALT + left",          hl.dsp.focus({ monitor = "l" }), { description = "Screens · Focus the screen left" })
bind(mainMod .. " + ALT + right",         hl.dsp.focus({ monitor = "r" }), { description = "Screens · Focus the screen right" })
bind(mainMod .. " + ALT + SHIFT + left",  trade_workspace("l"), { description = "Screens · Take the workspace to the screen left" })
bind(mainMod .. " + ALT + SHIFT + right", trade_workspace("r"), { description = "Screens · Take the workspace to the screen right" })


-- ── MEDIA KEYS ──────────────────────────────────────────────────────────────

-- · volume and brightness; brightness goes through the shell, which knows
-- · the focused screen and how to dim it
bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true, description = "Media · Volume up" })
bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true, description = "Media · Volume down" })
bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, description = "Media · Mute output" })
bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, description = "Media · Mute microphone" })
bind("XF86MonBrightnessUp",   hl.dsp.global("quickshell:brightnessUp"),                          { locked = true, repeating = true, description = "Media · Brightness up" })
bind("XF86MonBrightnessDown", hl.dsp.global("quickshell:brightnessDown"),                        { locked = true, repeating = true, description = "Media · Brightness down" })

-- · Acer laptops send XF86Launch6 for the microphone key
bind("XF86Launch6",           hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, description = "Media · Mute microphone (Acer)" })

-- · player; distinct descriptions so each key can be rebound separately
bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media · Play or pause" })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media · Play or pause, from the pause key" })
bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Media · Next track" })
bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Media · Previous track" })


-- ── SESSION ─────────────────────────────────────────────────────────────────

-- · the power button opens the session menu instead of powering off (logind
-- · is told to ignore it, see system/etc/systemd/logind.conf.d/). Some
-- · machines never report a short press, so the menu has keyboard binds too.
bind("SUPER + ALT + X",         hl.dsp.global("quickshell:session"), { description = "Session · Session menu" })
bind("CTRL + ALT + Delete",     hl.dsp.global("quickshell:session"), { description = "Session · Session menu, from CTRL + ALT + Delete" })
bind("XF86PowerOff",            hl.dsp.global("quickshell:session"), { description = "Session · Session menu, from the power button" })
bind("SUPER + ALT + L",         hl.dsp.global("quickshell:lock"),    { description = "Session · Lock the screen" })
bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"), { description = "Session · Exit Hyprland" })


-- ── UTILITIES ───────────────────────────────────────────────────────────────

-- · dpms actually powers the panel off, unlike brightness 0. Only this bind
-- · wakes it (key/mouse wake is off). The dispatcher toggles; it ignores
-- · a state argument.
bind(mainMod .. " + SHIFT + D", hl.dsp.dpms(), { locked = true, description = "Utilities · Turn the screen off or back on" })
bind(mainMod .. " + CTRL + R",  hl.dsp.exec_cmd("pkill -x quickshell; pkill -x qs; sleep 0.5; qs -p /etc/xdg/quickshell/impasto -d"), { description = "Utilities · Restart the shell" })


-- ── SHELL ───────────────────────────────────────────────────────────────────

-- · global shortcuts registered by the shell
bind(mainMod .. " + Space",     hl.dsp.global("quickshell:launcher"),   { description = "Shell · Open the launcher" })
bind("SUPER + S",         hl.dsp.global("quickshell:controls"),   { description = "Shell · Open the control centre" })
bind("SUPER + ALT + TAB",       hl.dsp.global("quickshell:overview"),   { description = "Shell · Open the workspace overview" })
bind("SUPER + SHIFT + S",     hl.dsp.global("quickshell:settings"),   { description = "Shell · Open settings" })
bind("SUPER + ALT + A",         hl.dsp.global("quickshell:appearance"), { description = "Shell · Open appearance" })
bind("SUPER + ALT + P", hl.dsp.global("quickshell:palette"),    { description = "Shell · Open the palette" })
bind("SUPER + ALT + U",         hl.dsp.global("quickshell:stats"),      { description = "Shell · Open system statistics" })
bind("SUPER + ALT + SHIFT + P", hl.dsp.global("quickshell:pet"),        { description = "Shell · Open the pet" })
bind("SUPER + ALT + G",         hl.dsp.global("quickshell:games"),      { description = "Shell · Open the games" })
bind("SUPER + ALT + N",         hl.dsp.global("quickshell:notes"),      { description = "Shell · Open the notes" })
bind("SUPER + ALT + K",         hl.dsp.global("quickshell:board"),      { description = "Shell · Open the task board" })

-- · key sheet, read from `hyprctl binds`. H, since / is SHIFT + 7 on a
-- · Spanish layout
bind("SUPER + ALT + H",         hl.dsp.global("quickshell:keys"),       { description = "Shell · Show every key" })

-- · zen: the bar away and its band to the windows; and the widgets away
bind(mainMod .. " + CTRL + B",  hl.dsp.global("quickshell:zen"),        { description = "Shell · Hide or show the bar" })
bind(mainMod .. " + CTRL + W",  hl.dsp.global("quickshell:widgets"),    { description = "Shell · Hide or show the desktop widgets" })
bind("SUPER + ALT + SHIFT + G", hl.dsp.global("quickshell:game"),       { description = "Shell · Turn game mode on or off" })

-- · packages panel (pacman + AUR); installs run in a terminal
bind("SUPER + ALT + I",         hl.dsp.global("quickshell:packages"),   { description = "Shell · Open the packages" })
bind("SUPER + ALT + M", hl.dsp.global("quickshell:machines"),   { description = "Shell · Open the virtual machines" })
bind("SUPER + ALT + O",         hl.dsp.global("quickshell:servers"),    { description = "Shell · Open the development servers" })
bind("SUPER + ALT + Y",         hl.dsp.global("quickshell:screentime"), { description = "Shell · Open the screen time" })
bind("", hl.dsp.global("quickshell:camera"),     { description = "Shell · Open the camera effects" })

-- · clipboard history is a launcher mode
bind("SUPER + SHIFT + C",         hl.dsp.global("quickshell:clipboard"),  { description = "Shell · Open the clipboard history" })

-- · emoji, a launcher mode too
bind("SUPER + ALT + E",    hl.dsp.global("quickshell:emoji"),      { description = "Shell · Pick an emoji" })

-- · colour picker (hyprpicker); the result goes to the clipboard
bind("SUPER + ALT + SHIFT + C", hl.dsp.global("quickshell:picker"),     { description = "Shell · Pick a colour off the screen" })

-- · capture surface. The direct captures below are unbound by default and
-- · can be assigned in Settings → Keys.
bind("SUPER + ALT + S", hl.dsp.global("quickshell:capture"), { description = "Shell · Open the capture surface" })
bind("SHIFT + Print",                   hl.dsp.global("quickshell:capture"), { description = "Shell · Open the capture surface, from Print" })
bind("SUPER + ALT + R", hl.dsp.global("quickshell:record"),  { description = "Shell · Start or stop recording the screen" })
bind("", hl.dsp.global("quickshell:captureRegion"), { description = "Shell · Capture a region" })
bind("", hl.dsp.global("quickshell:captureWindow"), { description = "Shell · Capture a window" })
bind("", hl.dsp.global("quickshell:captureScreen"), { description = "Shell · Capture the whole screen" })
bind("", hl.dsp.global("quickshell:captureEdit"),   { description = "Shell · Capture a region and annotate it" })
bind("", hl.dsp.global("quickshell:captureText"),   { description = "Shell · Read a region as text" })


-- ── KIRO ────────────────────────────────────────────────────────────────────

-- The Kiro scheme, as on kiro-hyprland-dms. Every bind has its own description, so
-- each one can be remapped in Settings → Keys.

-- · applications
bind(mainMod .. " + T",                  run(apps.terminal),     { description = "Applications · Open a terminal, from SUPER + T" })
bind("CTRL + ALT + Return",              run(apps.terminal),     { description = "Applications · Open a terminal, from CTRL + ALT + Return" })
bind("CTRL + ALT + T",                   run(apps.terminal),     { description = "Applications · Open a terminal, from CTRL + ALT + T" })
bind(mainMod .. " + SHIFT + F",          run(apps.file_manager), { description = "Applications · Open the file manager, from SUPER + SHIFT + F" })
bind(mainMod .. " + E",                  run(apps.editor),       { description = "Applications · Open the code editor" })
bind(mainMod .. " + SHIFT + B",          run(apps.browser),      { description = "Applications · Open the browser, from SUPER + SHIFT + B" })
bind(mainMod .. " + SHIFT + M",          run("spotify"),         { description = "Applications · Open Spotify" })
bind(mainMod .. " + CTRL + SHIFT + A",   run(apps.terminal .. " -e claude"), { description = "Applications · Open the AI agent" })
bind(mainMod .. " + V",                  run("pavucontrol"),     { description = "Applications · Open the volume control" })
bind(mainMod .. " + CTRL + A",           run("pavucontrol"),     { description = "Applications · Open the volume control, from SUPER + CTRL + A" })
bind("CTRL + ALT + U",                   run("pavucontrol"),     { description = "Applications · Open the volume control, from CTRL + ALT + U" })
bind("CTRL + ALT + END",                 run("alacritty --class btop -e btop"), { description = "Applications · Open the system monitor" })
bind("CTRL + SHIFT + Escape",            run("alacritty --class btop -e btop"), { description = "Applications · Open the system monitor, from CTRL + SHIFT + Escape" })

-- · CTRL + ALT launchers
bind("CTRL + ALT + A", run("alacritty-tweak-tool"),                { description = "Kiro apps · Alacritty tweak tool" })
bind("CTRL + ALT + Q", run("alacritty-tweak-tool"),                { description = "Kiro apps · Alacritty tweak tool, from CTRL + ALT + Q" })
bind("CTRL + ALT + B", run("brave --password-store=basic"),        { description = "Kiro apps · Brave" })
bind("CTRL + ALT + C", run("chromium -no-default-browser-check"),  { description = "Kiro apps · Chromium" })
bind("CTRL + ALT + G", run("chromium -no-default-browser-check"),  { description = "Kiro apps · Chromium, from CTRL + ALT + G" })
bind("CTRL + ALT + D", run("obs"),                                 { description = "Kiro apps · OBS Studio" })
bind("CTRL + ALT + E", run("archlinux-tweak-tool"),                { description = "Kiro apps · ArchLinux Tweak Tool" })
bind("CTRL + ALT + S", run("fish-tweak-tool"),                     { description = "Kiro apps · Fish tweak tool" })
-- KiroTux Hyprland Premium comes with the KiroTux ISOs: open it, or say where it is.
bind("CTRL + ALT + H", run("kiro-premium-hint hyprland"),          { description = "Kiro apps · KiroTux Hyprland Premium" })
bind("CTRL + ALT + F", run("firefox"),                             { description = "Kiro apps · Firefox" })
bind("CTRL + ALT + I", run("kiro-iso-builder"),                    { description = "Kiro apps · Kiro ISO builder" })
bind("CTRL + ALT + L", run(logout .. " --settings"),               { description = "Kiro apps · Logout settings" })
bind("CTRL + ALT + M", run("mintstick -m iso"),                    { description = "Kiro apps · USB image writer" })
bind("CTRL + ALT + O", run("opera"),                               { description = "Kiro apps · Opera" })
bind("CTRL + ALT + P", run("pamac-manager"),                       { description = "Kiro apps · Package manager" })
bind("CTRL + ALT + V", run("vivaldi-stable"),                      { description = "Kiro apps · Vivaldi" })
bind("CTRL + ALT + W", run("fastfetch-tweak-tool"),                { description = "Kiro apps · Fastfetch tweak tool" })
bind("CTRL + ALT + Z", run("fastfetch-tweak-tool"),                { description = "Kiro apps · Fastfetch tweak tool, from CTRL + ALT + Z" })

-- · function keys
bind(mainMod .. " + F1",  run(apps.browser),      { description = "Kiro apps · Browser, from SUPER + F1" })
bind(mainMod .. " + F2",  run(apps.editor),       { description = "Kiro apps · Code editor, from SUPER + F2" })
bind(mainMod .. " + F3",  run("inkscape"),        { description = "Kiro apps · Inkscape" })
bind(mainMod .. " + F4",  run("gimp"),            { description = "Kiro apps · GIMP" })
bind(mainMod .. " + F5",  run("meld"),            { description = "Kiro apps · Meld" })
bind(mainMod .. " + F6",  run("vlc"),             { description = "Kiro apps · VLC" })
bind(mainMod .. " + F7",  run("virtualbox"),      { description = "Kiro apps · VirtualBox" })
bind(mainMod .. " + F8",  run(apps.file_manager), { description = "Kiro apps · File manager, from SUPER + F8" })
bind(mainMod .. " + F9",  run("virt-manager"),    { description = "Kiro apps · Virt-manager" })
bind(mainMod .. " + F10", run("spotify"),         { description = "Kiro apps · Spotify, from SUPER + F10" })

-- · shell, from Kiro's chords
bind(mainMod .. " + D",            hl.dsp.global("quickshell:launcher"),   { description = "Shell · Open the launcher, from SUPER + D" })
bind(mainMod .. " + CTRL + Return", hl.dsp.global("quickshell:launcher"),  { description = "Shell · Open the launcher, from SUPER + CTRL + Return" })
bind(mainMod .. " + F11",          hl.dsp.global("quickshell:launcher"),   { description = "Shell · Open the launcher, from SUPER + F11" })
bind(mainMod .. " + F12",          hl.dsp.global("quickshell:launcher"),   { description = "Shell · Open the launcher, from SUPER + F12" })
bind(mainMod .. " + SHIFT + N",    hl.dsp.global("quickshell:controls"),   { description = "Shell · Open the control centre, from SUPER + SHIFT + N" })
bind(mainMod .. " + SHIFT + W",    hl.dsp.global("quickshell:appearance"), { description = "Shell · Open appearance, from SUPER + SHIFT + W" })

-- · session
bind(mainMod .. " + X",          run(logout), { description = "Session · Logout menu" })
bind(mainMod .. " + SHIFT + X",  run(logout), { description = "Session · Logout menu, from SUPER + SHIFT + X" })
bind("CTRL + ALT + K",           run(logout), { description = "Session · Logout menu, from CTRL + ALT + K" })
bind(mainMod .. " + CTRL + L",   hl.dsp.global("quickshell:lock"), { description = "Session · Lock the screen, from SUPER + CTRL + L" })
bind("CTRL + ALT + R",           hl.dsp.global("quickshell:lock"), { description = "Session · Lock the screen, from CTRL + ALT + R" })
bind(mainMod .. " + SHIFT + Q",  hl.dsp.window.close(), { description = "Windows · Close the focused window, from SUPER + SHIFT + Q" })
bind(mainMod .. " + Escape",     run("hyprctl kill"),   { description = "Session · Click a window to kill it" })
bind(mainMod .. " + CTRL + S",   run(keybindings),      { description = "Session · Show the Kiro keybindings" })
bind(mainMod .. " + SHIFT + R",  run("hyprctl reload"), { description = "Session · Reload Hyprland" })

-- · windows: groups, master, vim-style focus and resize, scratchpad
bind(mainMod .. " + G",            hl.dsp.group.toggle(),                         { description = "Windows · Toggle a group" })
bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ into_or_create_group = "l" }), { description = "Windows · Into the group left" })
bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ into_or_create_group = "r" }), { description = "Windows · Into the group right" })
bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ into_or_create_group = "u" }), { description = "Windows · Into the group up" })
bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ into_or_create_group = "d" }), { description = "Windows · Into the group down" })
bind(mainMod .. " + I",            hl.dsp.layout("addmaster"),                    { description = "Windows · Add a master" })
bind(mainMod .. " + SHIFT + I",    hl.dsp.layout("removemaster"),                 { description = "Windows · Remove a master" })
bind(mainMod .. " + H",            hl.dsp.focus({ direction = "l" }),             { description = "Windows · Focus the window left, from SUPER + H" })
bind(mainMod .. " + L",            hl.dsp.focus({ direction = "r" }),             { description = "Windows · Focus the window right, from SUPER + L" })
bind(mainMod .. " + K",            hl.dsp.focus({ direction = "u" }),             { description = "Windows · Focus the window up, from SUPER + K" })
bind(mainMod .. " + SHIFT + H",    hl.dsp.window.resize({ x = -50, y = 0,  relative = true }), { description = "Windows · Narrower" })
bind(mainMod .. " + SHIFT + L",    hl.dsp.window.resize({ x = 50,  y = 0,  relative = true }), { description = "Windows · Wider" })
bind(mainMod .. " + SHIFT + K",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }), { description = "Windows · Shorter" })
bind(mainMod .. " + SHIFT + J",    hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }), { description = "Windows · Taller" })
bind(mainMod .. " + U",            hl.dsp.workspace.toggle_special("scratchpad"), { description = "Windows · Show or hide the scratchpad" })
bind(mainMod .. " + SHIFT + U",    hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }), { description = "Windows · Send the window to the scratchpad" })

-- · workspaces, one by one
bind(mainMod .. " + period",      hl.dsp.focus({ workspace = "e+1" }), { description = "Workspaces · Next workspace, from SUPER + period" })
bind(mainMod .. " + comma",       hl.dsp.focus({ workspace = "e-1" }), { description = "Workspaces · Previous workspace, from SUPER + comma" })
bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "e+1" }), { description = "Workspaces · Next workspace, from SUPER + TAB" })
bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { description = "Workspaces · Previous workspace, from SUPER + SHIFT + TAB" })

-- · volume in small steps
bind("ALT + XF86AudioRaiseVolume", run("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true, description = "Media · Volume up 1%" })
bind("ALT + XF86AudioLowerVolume", run("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"),      { locked = true, repeating = true, description = "Media · Volume down 1%" })

-- · Variety; set_wallpaper_kiro hands each wallpaper to impasto, so the palette follows it
bind("ALT + N",         run("variety --next"),     { description = "Wallpaper · Next" })
bind("ALT + Right",     run("variety --next"),     { description = "Wallpaper · Next, from ALT + Right" })
bind("ALT + SHIFT + N", run("variety --next"),     { description = "Wallpaper · Next, from ALT + SHIFT + N" })
bind("ALT + P",         run("variety --previous"), { description = "Wallpaper · Previous" })
bind("ALT + Left",      run("variety --previous"), { description = "Wallpaper · Previous, from ALT + Left" })
bind("ALT + SHIFT + P", run("variety --previous"), { description = "Wallpaper · Previous, from ALT + SHIFT + P" })
bind("ALT + T",         run("variety --trash"),    { description = "Wallpaper · Trash" })
bind("ALT + SHIFT + T", run("variety --trash"),    { description = "Wallpaper · Trash, from ALT + SHIFT + T" })
bind("ALT + F",         run("variety --favorite"), { description = "Wallpaper · Favourite" })
bind("ALT + SHIFT + F", run("variety --favorite"), { description = "Wallpaper · Favourite, from ALT + SHIFT + F" })
bind("ALT + Up",        run("variety --pause"),    { description = "Wallpaper · Pause" })
bind("ALT + Down",      run("variety --resume"),   { description = "Wallpaper · Resume" })
bind("ALT + W",         run("variety --selector"), { description = "Wallpaper · Selector" })

-- · screenshots (kiro-screenshot, from kiro-wayland-dotfiles): a PNG in ~/Pictures/Screenshots,
-- · the clipboard and a notification. impasto's capture surface is on SHIFT + Print.
bind("Print",                   run("kiro-screenshot region"), { description = "Utilities · Screenshot a region" })
bind(mainMod .. " + Print",     run("kiro-screenshot screen"), { description = "Utilities · Screenshot the screen" })


-- ── LID ─────────────────────────────────────────────────────────────────────

-- Plain `hl.bind`, not profile keys. Kept out of monitors.lua: a `switch:`
-- bind in the same file as `hl.monitor()` calls is silently never registered.
--
-- `switch:on` is the lid closing. `locked = true` so it also fires on the lock
-- screen. The shell decides what to do (Settings → Displays).
hl.bind("switch:on:Lid Switch",  hl.dsp.global("quickshell:lidClosed"),
        { locked = true, description = "Session · The laptop lid was closed" })
hl.bind("switch:off:Lid Switch", hl.dsp.global("quickshell:lidOpened"),
        { locked = true, description = "Session · The laptop lid was opened" })
