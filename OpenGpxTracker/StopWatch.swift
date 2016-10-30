//
//  StopWatch.swift
//  OpenGpxTracker
//
//  Created by merlos on 21/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation

//
// This class handles the logic behind a stop watch timer
// It has two statuses: started or stopped. When started it counts time.
// when stopped it does not count time. You can
//

enum StopWatchStatus {
    case started
    case stopped
}

class StopWatch: NSObject {
    
    var tmpElapsedTime: TimeInterval = 0.0
    var startedTime: TimeInterval = 0.0
    var status: StopWatchStatus
    
    var timeInterval: TimeInterval = 0.01
    var timer = Timer()
    
    weak var delegate: StopWatchDelegate?
    
    override init() {
        self.tmpElapsedTime = 0.0
        self.status = StopWatchStatus.stopped
        
        super.init()
    }
    
    func start() {
        print("StopWatch: started")
        self.status = .started
        self.startedTime = Date.timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(StopWatch.updateElapsedTime), userInfo: nil, repeats: true)
    }
    
    func stop() {
        print("StopWatch: stopped")
        self.status = .stopped
        //add difference between start and stop to elapsed time
        let currentTime = Date.timeIntervalSinceReferenceDate
        let diff = currentTime - startedTime
        tmpElapsedTime = tmpElapsedTime + diff
        timer.invalidate()
    }
 
    func reset() {
        print("StopWatch: reset")
        timer.invalidate()
        self.tmpElapsedTime = 0.0
        self.startedTime = Date.timeIntervalSinceReferenceDate
        self.status = .stopped
    }
    
    var elapsedTime: TimeInterval {
        get {
            if self.status == .stopped {
                return self.tmpElapsedTime
            }
            let diff = Date.timeIntervalSinceReferenceDate - startedTime
            return tmpElapsedTime + diff
        }
    }
    
    // The returned string has the format MM:SS:ms
    // example: elapsed time: 3 min 30 sec 40ms => 03:30:40
    var elapsedTimeString: String {
        get {
            var tmpTime: TimeInterval = self.elapsedTime
            //calculate the minutes in elapsed time.
            let minutes = UInt32(tmpTime / 60.0)
            tmpTime -= (TimeInterval(minutes) * 60)

            //calculate the seconds in elapsed time.
            let seconds = UInt32(tmpTime)
            tmpTime -= TimeInterval(seconds)
        
            //find out the fraction of milliseconds to be displayed.
            let fraction = UInt32(tmpTime * 100)
        
            //add the leading zero for minutes, seconds and millseconds and store them as string constants
            let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
            let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
            let strFraction = fraction > 9 ? String(fraction):"0" + String(fraction)
        
            //concatenate minutes, seconds and milliseconds
            return "\(strMinutes):\(strSeconds):\(strFraction)"
        }
    }
    
    func updateElapsedTime() {
        self.delegate?.stopWatch(self, didUpdateElapsedTimeString: self.elapsedTimeString)
    }
}
