import Foundation
import Cocoa
import ServiceManagement

let launcherAppIdentifier = "io.burningtree.screenRDALauncher"

func applicationIsInStartUpItems() -> Bool {
    return _readFlag()
}

func toggleLaunchAtStartup() {
    let mode = !applicationIsInStartUpItems()
    if SMLoginItemSetEnabled(launcherAppIdentifier, mode) {
        _saveFlag(mode)
    }
}

func detectLaunchByHelper() {
    var startedAtLogin = false
    for app in NSWorkspace.sharedWorkspace().runningApplications {
        if app.bundleIdentifier == launcherAppIdentifier {
            startedAtLogin = true
        }
    }

    _saveFlag(startedAtLogin)
    NSDistributedNotificationCenter
        .defaultCenter()
        .postNotificationName("killme", object: NSBundle.mainBundle().bundleIdentifier!)
}

func _readFlag() -> Bool {
    return NSUserDefaults.standardUserDefaults().boolForKey("launchAtLogin")
}

func _saveFlag(flag: Bool) {
    NSUserDefaults.standardUserDefaults().setBool(flag, forKey: "launchAtLogin")
}
