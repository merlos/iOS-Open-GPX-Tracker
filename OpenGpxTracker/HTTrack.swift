//
//  HTTrack.swift
//  OpenGpxTracker
//
//  Created by Alan Heezen on 8/6/20.
//

import Foundation
import CoreLocation

// An implementation of SmoothTrack.swift to be merged into Open GPX Tracker

var grossErrorBound = 15.0
var spacingFactor = 1.0

class HTTrack {
    var previousLocation: CLLocation?
    var aggregator: HTAggregator?
    
    func filtered(_ rawLocation: CLLocation) -> CLLocation? {
        if previousLocation == nil { // New track
            previousLocation = rawLocation
            aggregator = HTAggregator()
            return nil
        } else { // send to aggregator
            
        }
        return rawLocation
    }
    init() {
        
    }
}
