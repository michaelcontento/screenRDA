//
//  AppDelegate.swift
//  screenRDALauncher
//
//  Created by Michael Contento on 19/05/16.
//  Copyright © 2016 BurningTree. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let mainAppIdentifier = "io.burningtree.screenRDA"
        var alreadyRunning = false

        let running = NSWorkspace.sharedWorkspace().runningApplications
        for app in running {
            if app.bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                break
            }
        }

        if !alreadyRunning {
            NSDistributedNotificationCenter
                .defaultCenter()
                .addObserver(self,
                             selector: #selector(AppDelegate.terminate),
                             name: "killme", object: mainAppIdentifier)

            let path = NSBundle.mainBundle().bundlePath as NSString
            var components = path.pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("screenRDA")

            let newPath = NSString.pathWithComponents(components)
            NSWorkspace.sharedWorkspace().launchApplication(newPath)
        } else {
            self.terminate()
        }

    }

    func terminate() {
        NSApp.terminate(nil)
    }

}
