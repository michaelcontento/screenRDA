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
    @IBOutlet weak var timeDisplay: NSMenuItem!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var updateTimer:NSTimer?
    var timer:Timer = Timer();

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

        updateTimer = NSTimer.scheduledTimerWithTimeInterval(
            1.0,
            target: self,
            selector: #selector(StatusMenuController.onTimerTick),
            userInfo: nil,
            repeats: true
        )

        registerNotifications()
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

        var hours:Int = 0;
        var minutes:Double = floor(runTime / 60);
        while (minutes >= 60) {
            hours += 1;
            minutes -= 60;
        }

        // TODO use singular for "1 hour" and "1 minute", we can handle this together with i18n!
        timeDisplay.title = String(format:"%d Hours %.f minutes", hours, minutes);

    }

    @IBAction func quitClicked(sender: NSMenuItem) {
        timer.update();
        NSApplication.sharedApplication().terminate(self)
    }
}
