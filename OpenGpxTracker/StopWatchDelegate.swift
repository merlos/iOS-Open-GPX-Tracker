//
//  StopWatchDelegate.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation

protocol StopWatchDelegate {
    
    func stopWatch(stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String)
}
