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
    
    var timeInterval: TimeInterval = 1.00 //seconds
    var timer = Timer()
    
    weak var delegate: StopWatchDelegate?
    
    override init() {
        self.tmpElapsedTime = 0.0 //seconds
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
    
    // The returned string has the format MM:SS or HhMM:SS
    // example: elapsed time: 3 min 30 sec => 03:30
    // example2: elapsed time 3h 40 min 30 sec => 3h40:20
    var elapsedTimeString: String {
        get {
            var tmpTime: TimeInterval = self.elapsedTime
            //calculate the minutes and hours in elapsed time.
            
            let hours = UInt32(tmpTime / 3600.0)
            tmpTime -= (TimeInterval(hours) * 3600)
            
            let minutes = UInt32(tmpTime / 60.0)
            tmpTime -= (TimeInterval(minutes) * 60)
           
            //calculate the seconds in elapsed time.
            let seconds = UInt32(tmpTime)
            tmpTime -= TimeInterval(seconds)
        
            //display hours only if >0
            let strHours = hours > 0 ? String(hours) + "h" : ""
            //add the leading zero for minutes, seconds and millseconds and store them as string constants
 
            let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
            let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
           
            //concatenate hours, minutes and seconds
            return "\(strHours)\(strMinutes):\(strSeconds)"
        }
    }
    
    func updateElapsedTime() {
        self.delegate?.stopWatch(self, didUpdateElapsedTimeString: self.elapsedTimeString)
    }
}
