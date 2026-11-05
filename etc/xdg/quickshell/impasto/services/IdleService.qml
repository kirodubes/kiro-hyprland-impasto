// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   I D L E   S E R V I C E                                                │
// │   idle actions · lock, screen off and suspend timeouts                   │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// Idle lock, screen off and suspend, in place of hypridle.
//
// Quickshell's `IdleMonitor` speaks `ext-idle-notify` directly, so timeouts
// follow the settings live with no daemon to restart. A timeout of zero means
// never. `respectInhibitors` lets video players hold all three off.
Singleton {
    id: root

    // Minutes; `IdleMonitor` takes seconds.
    readonly property int lockAfter: SettingsService.idleLock
    readonly property int screenAfter: SettingsService.idleScreen
    readonly property int suspendAfter: SettingsService.idleSuspend

    // Kiro: Quickshell 0.3.2 never arms an `IdleMonitor` whose timeout or
    // `enabled` changes after creation, and settings.json loads after these
    // exist, so each monitor is built by a `Variants` with its final value
    // and rebuilt when the setting moves.
    readonly property bool screenIdle: screenWatch.instances.length > 0 && screenWatch.instances[0].isIdle

    component Watch: IdleMonitor {
        required property int modelData
        timeout: modelData * 60
        respectInhibitors: true
    }

    // `lock()` is a no-op when already locked.
    readonly property Variants lockWatch: Variants {
        model: root.lockAfter > 0 ? [root.lockAfter] : []
        Watch {
            id: lockMonitor
            onIsIdleChanged: {
                if (lockMonitor.isIdle)
                    LockService.lock()
            }
        }
    }

    readonly property Variants screenWatch: Variants {
        model: root.screenAfter > 0 ? [root.screenAfter] : []
        Watch {
            id: screenMonitor
            onIsIdleChanged: root.screen(!screenMonitor.isIdle)
        }
    }

    // The session action locks and waits for the compositor to confirm
    // before suspending.
    readonly property Variants sleepWatch: Variants {
        model: root.suspendAfter > 0 ? [root.suspendAfter] : []
        Watch {
            id: sleepMonitor
            onIsIdleChanged: {
                if (sleepMonitor.isIdle)
                    SessionService.run("suspend")
            }
        }
    }

    // The dpms dispatcher toggles and ignores the state it is given, so this
    // sends a Lua chunk that reads the monitor and toggles only on mismatch,
    // making both directions idempotent.
    //
    // Waking matters: `key_press_enables_dpms` and `mouse_move_enables_dpms`
    // are off, so only this and `SUPER + SHIFT + D` turn the panel back on.
    // Only the first monitor is handled.
    function screen(on: bool): void {
        const disagrees = on ? "not m.dpms_status" : "m.dpms_status"
        Hyprland.dispatch(`function() local m = hl.get_monitors()[1]`
            + ` if m and ${disagrees} then hl.dispatch(hl.dsp.dpms()) end end`)
    }
}
