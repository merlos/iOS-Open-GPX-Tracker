//
//  StopWatchDelegate.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//

import Foundation

///
protocol StopWatchDelegate: class {
    
    /// Called when the stopwatch updated the elapsed time.
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String)
}
