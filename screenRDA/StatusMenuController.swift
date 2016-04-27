//
//  StatusMenuController.swift
//  screenRDA
//
//  Created by Michael Contento on 13/04/16.
//  Copyright © 2016 BurningTree. All rights reserved.
//

import Cocoa
import Foundation

class StatusMenuController: NSObject, NSMenuDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var timeDisplay: NSMenuItem!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var updateTimer:NSTimer?
    var timer:Timer = Timer();
    var timeLimit:Double = 8 * 60 * 60;

    let imageEmpty = NSImage(named: "HourGlassEmpty");
    let imageHalf = NSImage(named: "HourGlassHalf");
    let imageFull = NSImage(named: "HourGlassFull");

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
        statusItem.button?.image = imageEmpty;
        statusItem.menu = statusMenu;
        statusItem.menu?.delegate = self;

        onTimerTick();
        updateTimer = NSTimer.scheduledTimerWithTimeInterval(
            5 * 60.0,
            target: self,
            selector: #selector(StatusMenuController.onTimerTick),
            userInfo: nil,
            repeats: true
        );

        registerNotifications();
    }

    func menuWillOpen(menu: NSMenu) {
        onTimerTick();
    }

    func onScreenLocked() {
        timer.enable(false);
    }

    func onScreenUnlocked() {
        timer.enable();
    }

    func onScreenSaverStart() {
        timer.enable(false);
    }

    func onScreenSaverStop() {
        timer.enable();
    }

    func onTimerTick() {
        let runTime = timer.update();

        // Set current icon
        let isOverHalf = runTime >= (timeLimit / 2);
        let isOverLimit = runTime >= timeLimit;

        if isOverLimit {
            statusItem.button?.image = imageFull;
        } else if isOverHalf {
            statusItem.button?.image = imageHalf;
        } else {
            statusItem.button?.image = imageEmpty;
        }

        // Render time
        var hours:Int = 0;
        var minutes:Double = floor(runTime / 60);
        while (minutes >= 60) {
            hours += 1;
            minutes -= 60;
        }
        timeDisplay.title = formatHourAndMinute(hours, minutes: minutes);
    }

    func formatHourAndMinute(hours:Int, minutes:Double) -> String {
        var format = "";

        if (hours == 1) {
            format += "%d Hour ";
        } else if (hours > 1) {
            format += "%d Hours ";
        }

        if (minutes == 1) {
            format += "%.f Minute";
        } else if (minutes > 1) {
            format += "%.f Minutes";
        }

        if (hours == 0 && minutes == 0) {
            format = "< 1 Minute";
        }

        return String(format: format, hours, minutes);
    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        timer.update();
        NSApplication.sharedApplication().terminate(self)
    }
}
