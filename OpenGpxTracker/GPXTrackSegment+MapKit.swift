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
    public var overlay:MKPolyline {
        get{
            var coords: [CLLocationCoordinate2D] = self.trackPointsToCoordinates()
            let pl = MKPolyline(coordinates: &coords, count:  coords.count)
            return pl
            
        }
    }
    
    
    //Helper method to create the polyline. Returns the array of coordinates of the points
    //that belong to this segment
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D]{
        var coords: [CLLocationCoordinate2D] = []
        
        for point in self.trackpoints   {
            let pt = point as! GPXTrackPoint
            coords.append(pt.coordinate)
        }
        return coords
    }
}