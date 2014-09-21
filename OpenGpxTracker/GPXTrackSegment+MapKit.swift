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

extension GPXTrackSegment {
    
    public var overlay:MKPolyline {
        get{
            var coords: [CLLocationCoordinate2D] = self.trackPointsCoordinates()
            let pl = MKPolyline(coordinates: &coords, count:  coords.count)
            return pl
            
        }
    }
    
    func trackPointsCoordinates() -> [CLLocationCoordinate2D]{
        var coords: [CLLocationCoordinate2D] = []
        
        for point in self.trackpoints   {
            let pt = point as GPXTrackPoint
            coords.append(pt.coordinate)
        }
        return coords

    }
}