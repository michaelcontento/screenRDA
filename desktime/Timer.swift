//
//  Timer.swift
//  desktime
//
//  Created by Michael Contento on 25/04/16.
//  Copyright © 2016 BurningTree. All rights reserved.
//

import Foundation

class Timer: NSObject {
    var _lastTick:NSTimeInterval = NSDate().timeIntervalSince1970;
    var _lastDayOfYear:Int = -1;
    var _runTime:Double = 0;
    var _active:Bool = true;
    let _prefs = NSUserDefaults.standardUserDefaults();
    let _calendar =  NSCalendar.autoupdatingCurrentCalendar();
    let _dateFormatter = NSDateFormatter();

    func _getDayOfYear() -> Int {
        return _calendar.ordinalityOfUnit(
            .Day,
            inUnit: .Year,
            forDate: NSDate()
        )
    }

    func _getDateString() -> String {
        return _dateFormatter.stringFromDate(NSDate());
    }

    override init() {
        super.init();

        _dateFormatter.dateFormat = "yyyy-MM-dd";
        _lastDayOfYear = _getDayOfYear();

        _loadTime();
    }

    func _loadTime() {
        _runTime = _prefs.doubleForKey(_getDateString());
    }

    func _saveTime() {
        _prefs.setDouble(_runTime, forKey: _getDateString());
    }

    func enable(flag:Bool? = true) {
        if (_active == flag) {
            return;
        }

        if (_active) {
            update();
        } else {
            let now = NSDate().timeIntervalSince1970;
            _lastTick = now;
        }

        _active = flag!;
    }

    func update() -> Double {
        if (!_active) {
            return _runTime;
        }

        // Calculate time delta
        let now = NSDate().timeIntervalSince1970;
        let diff = now - _lastTick;
        _runTime += diff;
        _lastTick = now;

        // Detect day change
        let currentDayOfYear = _getDayOfYear();
        if (currentDayOfYear != _lastDayOfYear) {
            _lastDayOfYear = currentDayOfYear;
            _runTime = 0;
        } else {
            _saveTime();
        }

        return _runTime;
    }
}
