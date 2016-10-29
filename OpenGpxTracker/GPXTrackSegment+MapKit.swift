//
//  GPXTrackSegment+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//


import Foundation
import UIKit
import MapKit

//
//This extension adds some methods to work with mapkit
//
extension GPXTrackSegment {
  
    // Returns a mapkit polyline with the points of the segment.
    // This polyline can be directly plotted on the map as an overlay
    public var overlay: MKPolyline {
        get {
            var coords: [CLLocationCoordinate2D] = self.trackPointsToCoordinates()
            let pl = MKPolyline(coordinates: &coords, count:  coords.count)
            return pl
            
        }
    }
    
    
    //Helper method to create the polyline. Returns the array of coordinates of the points
    //that belong to this segment
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        
        for point in self.trackpoints {
            if let pt = point as? GPXTrackPoint {
                coords.append(pt.coordinate)
            }
        }
        return coords
    }
    
    //Calculates length in meters of the segment
    func length() -> CLLocationDistance {
        
        var length: CLLocationDistance = 0.0
        var distanceTwoPoints: CLLocationDistance
        //we need at least two points
        if self.trackpoints.count < 2 {
            return length
        }
        var prev: CLLocation? //previous
        for point in (self.trackpoints as? [GPXTrackPoint])! {
            let pt: CLLocation = CLLocation(latitude: Double(point.latitude), longitude: Double(point.longitude) )
            if prev == nil { //if first point => set it as previous and go for next
                prev = pt
                continue
            }
            distanceTwoPoints = pt.distance(from: prev!)
            length += distanceTwoPoints
            //set current point as previous point
            prev = pt
        }
        return length
    }    
}
