//
//  StopWatchDelegate.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//

import Foundation

/// This protocol is used to inform the delegate that the elapsed time was updated.
/// Provides the elapsed time as a string
protocol StopWatchDelegate: AnyObject {
    
    /// Called when the stopwatch updated the elapsed time.
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String)
}
