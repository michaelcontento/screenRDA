//
//  Timer.swift
//  screenRDA
//
//  Created by Michael Contento on 25/04/16.
//  Copyright © 2016 BurningTree. All rights reserved.
//

import Foundation

class Timer: NSObject {
    var lastTick: NSTimeInterval = NSDate().timeIntervalSince1970
    var lastDayOfYear: Int = -1
    var runTime: Double = 0
    var active: Bool = true
    let prefs = NSUserDefaults.standardUserDefaults()
    let calendar =  NSCalendar.autoupdatingCurrentCalendar()
    let dateFormatter = NSDateFormatter()

    func _getDayOfYear() -> Int {
        return calendar.ordinalityOfUnit(
            .Day,
            inUnit: .Year,
            forDate: NSDate()
        )
    }

    func _getDateString() -> String {
        return dateFormatter.stringFromDate(NSDate())
    }

    override init() {
        super.init()

        dateFormatter.dateFormat = "yyyy-MM-dd"
        lastDayOfYear = _getDayOfYear()

        _loadTime()
    }

    func _loadTime() {
        runTime = prefs.doubleForKey(_getDateString())
    }

    func _saveTime() {
        prefs.setDouble(runTime, forKey: _getDateString())
    }

    func enable(flag: Bool = true) {
        if active == flag {
            return
        }

        if active {
            update()
        } else {
            let now = NSDate().timeIntervalSince1970
            lastTick = now
        }

        active = flag
    }

    func update() -> Double {
        if !active {
            return runTime
        }

        // Calculate time delta
        let now = NSDate().timeIntervalSince1970
        let diff = now - lastTick
        runTime += diff
        lastTick = now

        // Detect day change
        let currentDayOfYear = _getDayOfYear()
        if currentDayOfYear != lastDayOfYear {
            lastDayOfYear = currentDayOfYear
            runTime = 0
        } else {
            _saveTime()
        }

        return runTime
    }
}
