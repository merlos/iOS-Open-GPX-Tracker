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
var saveNextPoint: Bool = false

class HTTrack {
    var previousLocation: CLLocation?
    var aggregator: HTAggregator?
    
    func filtered(_ rawLocation: CLLocation) -> CLLocation? {
        if previousLocation == nil { // New track - wait for an location with decent accuracy
            if rawLocation.accuracy() < grossErrorBound {
                previousLocation = rawLocation
                aggregator = HTAggregator()
                return rawLocation // pass it on to the map
            } else {
                return nil
            }
        } else {
            if saveNextPoint {
                // This won't occur until I find a way to handle this feature in the VC
                // ¿¿ Do a reach-around, slipping the aggregated point into the map
                // and returning the rawLocation to be processed by the VC??
                // Another possibility would be to return an array and loop through it in the VC
                // map.addPointToCurrentTrackSegmentAtLocation(aggregator.evaluate)
                // also start a new aggregator
                saveNextPoint = false
                return rawLocation
            } else {
                if aggregator!.add(rawLocation) >= spacingFactor * rawLocation.accuracy() {
                    let filteredLocation = aggregator?.evaluate()
                    aggregator = HTAggregator()
                    return filteredLocation
                }
            }
        }
        return nil // can't get here
    }
    init() {
        
    }
}

//    override func add(_ newPoint: CLLocation) -> Bool {
//        if points.count <= 0 {
//            if super.add(newPoint) { //let Track.add handle an empty TRack
//                aggregator = WeightedAggregator()
//                return true
//            } else {
//                return false
//            }
//        } else {
//            if saveNextPoint {
//                if super.add(aggregator!.evaluate()) && super.add(newPoint) {
//                    aggregator = WeightedAggregator()
//                    saveNextPoint = false
//                    return true
//                }
//            }
//            let newAccuracy = newPoint.accuracy()
//            if (aggregator!.add(newPoint)) >= spacingFactor * newAccuracy {
//                // update elevationFilter and pass to .evaluate to replace altitude
//                let aggregatedPoint = aggregator?.evaluate()
//                let filteredAltitude = (elevationFilter?.update(toLocation: aggregatedPoint!))!
//                let finalPoint = aggregator?.reEvaluate(aggregatedPoint!, withFilteredAltitude: filteredAltitude)
//                if super.add(finalPoint!) {
//                    aggregator = WeightedAggregator()
//                    return true
//                }
//            }
//            return false
//
//        }
//    }
//    init(withElevationFilter filter: ElevationFilter?,
//            withSpacingFactor factor: Double,
//            withGrossErrorBound error: CLLocationDistance) {
//        elevationFilter = filter
//        super.init(withSpacingFactor: factor,
//                   withGrossErrorBound: error)
//    }
//
//}
