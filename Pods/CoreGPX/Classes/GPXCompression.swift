//
//  GPXParser+Lossy.swift
//  Pods
//
//  Created by Vincent Neo on 25/10/19.
//

import Foundation

/// Simple class for some basic lossy compression.
public class GPXCompression {
    
    /// Use this function to compression `GPXRoot`.
    ///
    /// Type of compression can be chose here.
    public static func compress(gpx: GPXRoot, by type: lossyTypes, affecting types: [lossyOptions]) -> GPXRoot {
        switch type {
            
        case .randomRemoval: return lossyRandom(gpx, types: types, percent: type.value())
        case .stripNearbyData: return stripNearbyData(gpx, types: types, distanceRadius: type.value())
        case .stripDuplicates: return stripDuplicates(gpx, types: types)
            
        }
    }
    
    /// Currently supported types of compression.
    public enum lossyTypes {
        
        /// Removal of duplicated points.
        case stripDuplicates
        /// Removal of points with nearby co ordinates, subject to distance radius provided.
        case stripNearbyData(distanceRadius: Double)
        /// Removal of points in a random manner, with a percentage of removal.
        case randomRemoval(percentage: Double)
        
        /// Internal function to get a value, should it be supported by the type.
        func value() -> Double {
            switch self {
            case .stripNearbyData(distanceRadius: let rad): return rad
            case .randomRemoval(percentage: let percent): return percent
            default: fatalError("GPXParserLossyTypes: type of id \(self.rawValue) has no value to get")
            }
        }
    }

    /// Selectable scope of removal of points.
    public enum lossyOptions {
        /// Remove Track Points
        case trackpoint
        /// Remove Waypoints
        case waypoint
        /// Remove Route Points
        case routepoint
    }
    
    /// Internal function to call for when removal of duplicates is needed.
    ///
    /// - Parameters:
    ///    - gpx: GPX data in an instance.
    ///    - types: Chosen point types, scope of lossy removals.
    ///
    static func stripDuplicates(_ gpx: GPXRoot, types: [lossyOptions]) -> GPXRoot {
        let gpx = gpx
        
        var lastWaypoints = [GPXWaypoint]()
        var lastTrackpoints = [GPXTrackPoint]()
        var lastRoutepoints = [GPXRoutePoint]()

        if types.contains(.waypoint) {
            for wpt in gpx.waypoints {
                if wpt.compareCoordinates(with: lastWaypoints.last) {
                    lastWaypoints.append(wpt)
                    continue
                }
                else {
                    if lastWaypoints.isEmpty {
                        lastWaypoints.append(wpt)
                        continue
                    }
                    for (index,dupWpt) in lastWaypoints.enumerated() {
                        if index == lastWaypoints.endIndex - 1 {
                            lastWaypoints = [GPXWaypoint]()
                            lastWaypoints.append(wpt)
                        }
                        else if let i = gpx.waypoints.firstIndex(of: dupWpt) {
                            gpx.waypoints.remove(at: i)
                        }
                    }

                }
            }

            lastWaypoints = [GPXWaypoint]()
        }
        
        if types.contains(.trackpoint) {
             for track in gpx.tracks {
                        for segment in track.segments {
                            for trkpt in segment.points {
                                if trkpt.compareCoordinates(with: lastTrackpoints.last) {
                                    lastTrackpoints.append(trkpt)
                                    continue
                                }
                                else {
                                    if lastTrackpoints.isEmpty {
                                        lastTrackpoints.append(trkpt)
                                        continue
                                    }
                                    for (index,dupTrkpt) in lastTrackpoints.enumerated() {
                                        if index == lastTrackpoints.endIndex - 1 {
                                            lastTrackpoints = [GPXTrackPoint]()
                                            lastTrackpoints.append(trkpt)
                                        }
                                        else if let i = segment.points.firstIndex(of: dupTrkpt) {
                                            segment.points.remove(at: i)
                                        }
                                    }

                                }
                            }
                            lastTrackpoints = [GPXTrackPoint]()
                        }
                    }
         }
        
         
         if types.contains(.routepoint) {
             for route in gpx.routes {
                for rtept in route.points {
                   if rtept.compareCoordinates(with: lastRoutepoints.last) {
                        lastRoutepoints.append(rtept)
                        continue
                    }
                    else {
                        if lastRoutepoints.isEmpty {
                            lastRoutepoints.append(rtept)
                            continue
                        }
                        for (index,dupRtept) in lastRoutepoints.enumerated() {
                            if index == lastRoutepoints.endIndex - 1 {
                                lastRoutepoints = [GPXRoutePoint]()
                                lastRoutepoints.append(rtept)
                            }
                            else if let i = route.points.firstIndex(of: dupRtept) {
                                route.points.remove(at: i)
                            }
                        }

                    }
                }
                lastRoutepoints = [GPXRoutePoint]()
             }
         }
        
        return gpx
    }
    
    /// Internal function to call for when removal of nearby points is needed.
    ///
    /// - Parameters:
    ///    - gpx: GPX data in an instance.
    ///    - types: Chosen point types, scope of lossy removals.
    ///    - distanceRadius: Radius to be affected. In unit of metres (m)
    ///
    static func stripNearbyData(_ gpx: GPXRoot, types: [lossyOptions], distanceRadius: Double = 100) -> GPXRoot {
        let gpx = gpx
        var lastPointCoordinates: GPXWaypoint?

        if types.contains(.waypoint) {
            for wpt in gpx.waypoints {
                if let distance = GPXCompressionCalculate.getDistance(from: lastPointCoordinates, and: wpt) {
                    if distance < distanceRadius {
                        if let i = gpx.waypoints.firstIndex(of: wpt) {
                            gpx.waypoints.remove(at: i)
                        }
                        lastPointCoordinates = nil
                        continue
                    }
                }
                lastPointCoordinates = wpt
            }
            lastPointCoordinates = nil
        }
        
        if types.contains(.trackpoint) {
             for track in gpx.tracks {
                        for segment in track.segments {
                            for trkpt in segment.points {
                                if let distance = GPXCompressionCalculate.getDistance(from: lastPointCoordinates, and: trkpt) {
                                    if distance < distanceRadius {
                                        if let i = segment.points.firstIndex(of: trkpt) {
                                            segment.points.remove(at: i)
                                        }
                                        lastPointCoordinates = nil
                                        continue
                                    }
                                }
                                lastPointCoordinates = trkpt
                            }
                            lastPointCoordinates = nil
                        }
                    }
         }
        
         
         if types.contains(.routepoint) {
             for route in gpx.routes {
                for rtept in route.points {
                    if let distance = GPXCompressionCalculate.getDistance(from: lastPointCoordinates, and: rtept) {
                        if distance < distanceRadius {
                            if let i = route.points.firstIndex(of: rtept) {
                                route.points.remove(at: i)
                            }
                            lastPointCoordinates = nil
                            continue
                        }
                    }
                    lastPointCoordinates = rtept
                }
                lastPointCoordinates = nil
             }
         }
        
        return gpx
    }
    
    /// Internal function to call for when removal of points randomly is needed.
    ///
    /// - Parameters:
    ///    - gpx: GPX data in an instance.
    ///    - types: Chosen point types, scope of lossy removals.
    ///    - percent: Pecentage to be accepted to be removed. Expressed in decimal. (20% --> 0.2)
    ///
    static func lossyRandom(_ gpx: GPXRoot, types: [lossyOptions], percent: Double = 0.2) -> GPXRoot {
        
        let gpx = gpx
        let wptCount = gpx.waypoints.count
        
        if types.contains(.waypoint) {
            if wptCount != 0 {
                let removalAmount = Int(percent * Double(wptCount))
                for i in 0...removalAmount {
                    let randomInt = Int.random(in: 0...wptCount - (i+1))
                    gpx.waypoints.remove(at: randomInt)
                }
            }
        }
        
        if types.contains(.trackpoint) {
            for track in gpx.tracks {
                       for segment in track.segments {
                           let trkptCount = segment.points.count
                           if trkptCount != 0 {
                               let removalAmount = Int(percent * Double(trkptCount))
                               for i in 0...removalAmount {
                                   let randomInt = Int.random(in: 0...trkptCount - (i+1))
                                   segment.points.remove(at: randomInt)
                               }
                           }
                       }
                   }
        }
       
        
        if types.contains(.routepoint) {
            for route in gpx.routes {
                let rteCount = route.points.count
                if rteCount != 0 {
                    let removalAmount = Int(percent * Double(rteCount))
                    for i in 0...removalAmount {
                        let randomInt = Int.random(in: 0...rteCount - (i+1))
                        route.points.remove(at: randomInt)
                    }
                }
            }
        }
        
        return gpx
        
    }
    
}

/// Raw Representable for Lossy types enum
extension GPXCompression.lossyTypes: RawRepresentable {
    /// Represented as an integer
    public typealias RawValue = Int
    
    /// Initializes raw
    public init?(rawValue: Int, value: Double?) {
        switch rawValue {
        case 0:
            self = .stripDuplicates // init will still run even if value has something.
        case 1:
            guard let value = value else { fatalError("\(rawValue): Invalid value.") }
            self = .stripNearbyData(distanceRadius: value)
        case 2:
            guard let value = value else { fatalError("\(rawValue): Invalid value.") }
            self = .randomRemoval(percentage: value)
        default:
            fatalError("Invalid rawValue.")
        }
    }
    
    /// Default Initializer. Not recommended for use.
    public init?(rawValue: Int) {
        if rawValue == 0 {
            self = .stripDuplicates
        }
        else {
            fatalError("GPXCompression.lossyTypes: This initalizer is NOT supported for this associated type. Please use init(rawValue:value:) instead.")
        }
    }
    
    /// Raw Value
    public var rawValue: Int {
        switch self {
        case .stripDuplicates: return 0
        case .stripNearbyData: return 1
        case .randomRemoval: return 2
        }
    }
    
}


/// Extension for distance between points calculation, without `CoreLocation` APIs.
class GPXCompressionCalculate {
    
    /// Calculates distance between two coordinate points, returns in metres (m).
    ///
    /// Code from https://github.com/raywenderlich/swift-algorithm-club/tree/master/HaversineDistance
    /// Licensed under MIT license
    static func haversineDistance(la1: Double, lo1: Double, la2: Double, lo2: Double, radius: Double = 6367444.7) -> Double {
        
        let haversin = { (angle: Double) -> Double in
            return (1 - cos(angle))/2
        }
        
        let ahaversin = { (angle: Double) -> Double in
            return 2*asin(sqrt(angle))
        }
        
        // Converts from degrees to radians
        let dToR = { (angle: Double) -> Double in
            return (angle / 360) * 2 * .pi
        }
        
        let lat1 = dToR(la1)
        let lon1 = dToR(lo1)
        let lat2 = dToR(la2)
        let lon2 = dToR(lo2)
        
        return radius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1))
    }
    
    /// Gets distance from any GPX point type
    static func getDistance<pt: GPXWaypoint>(from first: pt?, and second: pt?) -> Double? {
        guard let lat1 = first?.latitude, let lon1 = first?.longitude, let lat2 = second?.latitude, let lon2 = second?.longitude else { return nil }
        
        return haversineDistance(la1: lat1, lo1: lon1, la2: lat2, lo2: lon2)
    }
    
}

/// Extension to allow for easy coordinates comparison.
extension GPXWaypoint {
    /// Private function for coordinates comparsions
    fileprivate func compareCoordinates<pt: GPXWaypoint>(with pointType: pt?) -> Bool {
        guard let pointType = pointType else { return false }
        return (self.latitude == pointType.latitude && self.longitude == pointType.longitude) ? true : false
    }
}

