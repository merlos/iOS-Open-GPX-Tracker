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
    case Started
    case Stopped
}

class StopWatch: NSObject {
    
    var tmpElapsedTime: NSTimeInterval = 0.0
    var startedTime: NSTimeInterval = 0.0
    var status: StopWatchStatus
    
    var timeInterval: NSTimeInterval = 0.01
    var timer = NSTimer()
    
    var delegate: StopWatchDelegate?
    
    override init() {
        self.tmpElapsedTime = 0.0
        self.status = StopWatchStatus.Stopped
        
        super.init()
    }
    
    func start() {
        print("StopWatch: started")
        self.status = .Started
        self.startedTime = NSDate.timeIntervalSinceReferenceDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: #selector(StopWatch.updateElapsedTime), userInfo: nil, repeats: true)
    }
    
    func stop() {
        print("StopWatch: stopped")
        self.status = .Stopped
        //add difference between start and stop to elapsed time
        let currentTime = NSDate.timeIntervalSinceReferenceDate()
        let diff = currentTime - startedTime
        tmpElapsedTime = tmpElapsedTime + diff
        timer.invalidate()
    }
 
    func reset() {
        print("StopWatch: reset")
        timer.invalidate()
        self.tmpElapsedTime = 0.0
        self.startedTime = NSDate.timeIntervalSinceReferenceDate()
        self.status = .Stopped
    }
    
    var elapsedTime: NSTimeInterval {
        get {
            if self.status == .Stopped {
                return self.tmpElapsedTime
            }
            let diff = NSDate.timeIntervalSinceReferenceDate() - startedTime
            return tmpElapsedTime + diff
        }
    }
    
    // The returned string has the format MM:SS:ms
    // example: elapsed time: 3 min 30 sec 40ms => 03:30:40
    var elapsedTimeString: String {
        get {
            var tmpTime: NSTimeInterval = self.elapsedTime
            //calculate the minutes in elapsed time.
            let minutes = UInt8(tmpTime / 60.0)
            tmpTime -= (NSTimeInterval(minutes) * 60)

            //calculate the seconds in elapsed time.
            let seconds = UInt8(tmpTime)
            tmpTime -= NSTimeInterval(seconds)
        
            //find out the fraction of milliseconds to be displayed.
            let fraction = UInt8(tmpTime * 100)
        
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
