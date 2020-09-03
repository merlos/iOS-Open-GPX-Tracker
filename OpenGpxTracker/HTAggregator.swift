//
//  HTAggregator.swift
//  OpenGpxTracker
//
//  Created by Alan Heezen on 8/12/20.
//  Modification of HikeTracker.Aggregator
//      for Open GPX Tracker

//	An HTTrack instance refuses to accept any location until its accuracy has
//	come down into a reasonable range. Currently that is set at 15 meters, which
//	my phone usually reaches within a minute or so of starting.
//
//	Once it has a starting point, HTTrack creates an HTAggregator instance and
//	starts feeding it the raw location data. The HTAggregator.add(:CLLocation)
//	method keeps a 6-dimensional (the three spatial coordinates, the two
//	accuracies, and time) running average of these locations and calculates the
//	horizontal distance back to the starting location.
//
//	It returns this distance to the HTTrack instance, which has the option of
//	proceeding with the aggregation or calling the evaluate() function to convert
//	the running average into a full-blown CLLocation object (which is passed to
//	the MapView) and starting over with a fresh HTAggregator.
//

import Foundation
import CoreLocation

class HTAggregator {
    //MARK: Properties
    var startingPoint: CLLocation?
    
    //MARK: Private Properties
    private var longitude:CLLocationDistance = 0.0, latitude:CLLocationDistance = 0.0, altitude:CLLocationDistance = 0.0
    private var hAccuracy:CLLocationAccuracy = 0.0, vAccuracy:CLLocationAccuracy = 0.0
    private var timeStamp:TimeInterval = 0.0
    private var weightSum: Double = 0.0
    private var count:Int = 0

    //MARK: Public Methods
    func add(_ point: CLLocation) -> CLLocationDistance {
        let weight = weighter(point)
        
        // Include point in the weighted average
        longitude += weight * point.coordinate.longitude
        latitude += weight * point.coordinate.latitude
        altitude += weight * point.altitude
        hAccuracy += weight * point.horizontalAccuracy
        vAccuracy += weight * point.verticalAccuracy
        timeStamp += weight * point.timestamp.timeIntervalSinceReferenceDate
        weightSum += weight
        count += 1
        
        // Compute the distance from the starting point
        if startingPoint == nil {
            // Initialize the starting point
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
    
    //MARK: Private Methods
    // This is just here to facilitate experimentation with weighting schemes
    private func weighter(_ point: CLLocation) -> Double {
        return 1.0 / point.accuracy()
    }
}

//func show(n: Int, point: CLLocation, message: String) {
//    print("line #", n, "at ", point, "|| ", message)
//}
