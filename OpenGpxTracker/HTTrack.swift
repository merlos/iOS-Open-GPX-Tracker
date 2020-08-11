//
//  HTTrack.swift
//  OpenGpxTracker
//
//  Created by Alan Heezen on 8/6/20.
//

import Foundation
import CoreLocation

// An implementation of SmoothTrack.swift to be merged into Open GPX Tracker
// Should be ready for a Pull request now

class HTTrack {
    var previouslocation: CLLocation?
    
    func filtered(_ rawLocation: CLLocation) -> CLLocation? {
        return rawLocation
    }
    init() {
        
    }
}

