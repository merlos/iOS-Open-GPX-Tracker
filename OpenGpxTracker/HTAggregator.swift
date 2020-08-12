//
//  HTAggregator.swift
//  OpenGpxTracker
//
//  Created by Alan Heezen on 8/12/20.
//  Modification of HikeTracker.Aggregator
//      for Open GPX Tracker
//

import Foundation
import CoreLocation

class HTAggregator {
    var startingPoint: CLLocation?
    
    // Accumulators
    var longitude:CLLocationDistance = 0.0, latitude:CLLocationDistance = 0.0, altitude:CLLocationDistance = 0.0
    var hAccuracy:CLLocationAccuracy = 0.0, vAccuracy:CLLocationAccuracy = 0.0
    var timeStamp:TimeInterval = 0.0
    var weightSum: Double = 0.0
    var count:Int = 0

    func weighter(_ point: CLLocation) -> Double {
        return 1.0 / point.accuracy()
    }

    func add(_ point: CLLocation) -> CLLocationDistance {
        let weight = weighter(point)
        
        longitude += weight * point.coordinate.longitude
        latitude += weight * point.coordinate.latitude
        altitude += weight * point.altitude
        hAccuracy += weight * point.horizontalAccuracy
        vAccuracy += weight * point.verticalAccuracy
        timeStamp += weight * point.timestamp.timeIntervalSinceReferenceDate
        weightSum += weight
        count += 1
        if startingPoint == nil {
            startingPoint = point
            return 0.0
        } else {
            let horizontalLocationSoFar = CLLocation(latitude: latitude / weightSum, longitude: longitude / weightSum)
            let result = horizontalLocationSoFar.distance(from: startingPoint!)

            return result
        }
    }

    func evaluate() -> CLLocation {
        let hLocation = CLLocationCoordinate2D(latitude: latitude / weightSum, longitude: longitude / weightSum)
        let time = Date(timeIntervalSinceReferenceDate: timeStamp / weightSum)
        let result = CLLocation(coordinate: hLocation,
                   altitude: altitude / weightSum,  //// This is where to feed in the elevation filter
                   horizontalAccuracy: hAccuracy / weightSum, verticalAccuracy: vAccuracy / weightSum,
                   timestamp: time)
        return result
    }
    
    func reEvaluate(_ location:CLLocation, withFilteredAltitude filteredAltitude: CLLocationDistance) -> CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
            altitude: filteredAltitude,
            horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy,
            timestamp: location.timestamp)
    }
}

func show(n: Int, point: CLLocation, message: String) {
    print("line #", n, "at ", point, "|| ", message)
}
