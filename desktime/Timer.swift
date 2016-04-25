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
    var _timeLimit:Double = 8 * 60 * 60 * 1000;
    var _active:Bool = true;

    func _getDayOfYear() -> Int {
        let date = NSDate()
        let cal = NSCalendar.currentCalendar()
        return cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: date)
    }

    func enable(flag:Bool? = false) {
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
        }

        return _runTime;
    }
}
