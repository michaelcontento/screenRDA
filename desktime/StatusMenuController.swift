//
//  StatusMenuController.swift
//  desktime
//
//  Created by Michael Contento on 13/04/16.
//  Copyright © 2016 BurningTree. All rights reserved.
//

import Cocoa
import Foundation

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var updateTimer:NSTimer?
    var lastTick:NSTimeInterval = NSDate().timeIntervalSince1970
    var runTime:Double = 0
    var showDots:Bool = true
    var screenIsLocked:Bool = false
    var screensaverIsRunning:Bool = false;

    let eventMap: [String: Selector] = [
        "com.apple.screenIsLocked": #selector(onScreenLocked),
        "com.apple.screenIsUnlocked": #selector(onScreenUnlocked),
        "com.apple.screensaver.didstart": #selector(onScreenSaverStart),
        "com.apple.screensaver.didstop": #selector(onScreenSaverStop),
    ]

    func registerNotifications() {
        let notificationCenter = NSDistributedNotificationCenter.defaultCenter()
        for (event, selector) in  eventMap {
            notificationCenter.addObserver(self, selector: selector, name: event, object: nil)
        }
    }

    deinit {
        NSDistributedNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func awakeFromNib() {
        statusItem.title = "00:00"
        statusItem.menu = statusMenu

        updateTimer = NSTimer.scheduledTimerWithTimeInterval(
            1.0,
            target: self,
            selector: #selector(StatusMenuController.onTimerTick),
            userInfo: nil,
            repeats: true
        )

//        FIXME: Text is cut off
//        let icon = NSImage(named: "StatusIcon")
//        icon?.template = true
//        statusItem.image = icon

        registerNotifications()
    }

    func isIdle() -> Bool {
        return screensaverIsRunning || screenIsLocked
    }

    func onScreenLocked() {
        screenIsLocked = true
    }

    func onScreenUnlocked() {
        screenIsLocked = false
    }

    func onScreenSaverStart() {
        screensaverIsRunning = true
    }

    func onScreenSaverStop() {
        screensaverIsRunning = false
    }

    func onTimerTick() {
        // Calculate time delta
        let now = NSDate().timeIntervalSince1970;
        let diff = now - lastTick;

        if !isIdle() {
            runTime += diff;
        }

        // Update attributes
        lastTick = now;
        showDots = !showDots;

        // Render new time
        var hours:Int = 0;
        var minutes:Double = floor(runTime / 60);
        while (minutes >= 60) {
            hours += 1;
            minutes -= 60;
        }
        statusItem.title = String(format:"%02d", hours)
            + (showDots ? ":" : " ")
            + String(format:"%02.f", minutes);
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
