//
//  StopWatch.swift
//  OpenGpxTracker
//
//  Created by merlos on 21/09/14.
//

import Foundation

/// Posible status of the stop watch
enum StopWatchStatus {
    
    /// It is counting time
    case started
    
    /// It is not counting time
    case stopped
}

///
/// This class handles the logic behind a stop watch timer
/// It has two statuses: started or stopped. When started it counts time.
/// when stopped it does not count time.
///
class StopWatch: NSObject {
    
    /// Temporary elapsed time.
    var tmpElapsedTime: TimeInterval = 0.0
    
    /// Time the stopwatch started
    var startedTime: TimeInterval = 0.0
    
    /// Current status
    var status: StopWatchStatus
    
    /// Defines the interval in which the delegate is called
    var timeInterval: TimeInterval = 1.00 //seconds
    
    /// Timer that handles the synchronous notifications calls to `updateElapsedTime`
    var timer = Timer()
    
    /// Delegate that receives the time updates every `timeInterval`
    weak var delegate: StopWatchDelegate?
    
    /// Initializes the stopWatch with elapsed time 0.00 and `stopped` stop watch status.
    override init() {
        self.tmpElapsedTime = 0.0 //seconds
        self.status = StopWatchStatus.stopped
        super.init()
    }
    
    /// Start counting time
    func start() {
        print("StopWatch: started")
        self.status = .started
        self.startedTime = Date.timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                     target: self, selector: #selector(StopWatch.updateElapsedTime),
                                     userInfo: nil, repeats: true)
    }
    
    /// Stops counting time
    func stop() {
        print("StopWatch: stopped")
        self.status = .stopped
        //add difference between start and stop to elapsed time
        let currentTime = Date.timeIntervalSinceReferenceDate
        let diff = currentTime - startedTime
        tmpElapsedTime += diff
        timer.invalidate()
    }
 
    /// Sets everything to 0.0
    func reset() {
        print("StopWatch: reset")
        timer.invalidate()
        self.tmpElapsedTime = 0.0
        self.startedTime = Date.timeIntervalSinceReferenceDate
        self.status = .stopped
    }
    
    /// Current elapsed time.
    var elapsedTime: TimeInterval {
        if self.status == .stopped {
            return self.tmpElapsedTime
        }
        let diff = Date.timeIntervalSinceReferenceDate - startedTime
        return tmpElapsedTime + diff
    }
    
    ///
    /// Returns the elapsed time as a String with the format `MM:SS` or `HhMM:SS`
    ///
    ///  Examples:
    ///    1. if elapsed time is 3 min 30 sec, returns `03:30`
    ///    2. 3h 40 min 30 sec, returns  `3h40:20`
    ///
    var elapsedTimeString: String {
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
    
    /// Calls the delegate (didUpdateElapsedTimeString) to inform there was an update of the elapsed time.
    @objc func updateElapsedTime() {
        self.delegate?.stopWatch(self, didUpdateElapsedTimeString: self.elapsedTimeString)
    }
}
