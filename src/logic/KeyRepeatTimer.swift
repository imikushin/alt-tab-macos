import Cocoa
import ShortcutRecorder

class KeyRepeatTimer {
    static var timer: Timer?
    static var isARepeat = false

    static func toggleRepeatingKeyPreviousWindow() {
        if let shortcut = ControlsTab.shortcuts["previousWindowShortcut"],
           shortcut.shortcut.keyCode == .none {
            toggleRepeatingKey(shortcut) {
                App.app.previousWindowShortcutWithRepeatingKey()
            }
        }
    }

    static func toggleRepeatingKeyNextWindow() {
        let suffix = App.app.shortcutIndex == 0 ? "" : "2"
        if let shortcut = ControlsTab.shortcuts["nextWindowShortcut" + suffix] {
            toggleRepeatingKey(shortcut) {
                ControlsTab.shortcutsActions["nextWindowShortcut" + suffix]!()
            }
        }
    }

    private static func toggleRepeatingKey(_ atShortcut: ATShortcut, _ block: @escaping () -> Void) {
        if (timer == nil || !timer!.isValid) {
            let repeatRate = ticksToSeconds(defaults.string(forKey: "KeyRepeat") ?? "6")
            let initialDelay = ticksToSeconds(defaults.string(forKey: "InitialKeyRepeat") ?? "25")
            timer = Timer(fire: Date(timeIntervalSinceNow: initialDelay), interval: repeatRate, repeats: true, block: { _ in
                if atShortcut.state == .up {
                    timer?.invalidate()
                } else {
                    DispatchQueue.main.async {
                        block()
                    }
                }
            })
            CFRunLoopAddTimer(BackgroundWork.repeatingKeyThread.runLoop, timer!, .defaultMode)
        }
    }

    private static func ticksToSeconds(_ appleNumber: String) -> Double {
        let refreshRate = NSScreen.preferred().refreshRate() ?? 60
        return Double(appleNumber)! / refreshRate
    }
}
