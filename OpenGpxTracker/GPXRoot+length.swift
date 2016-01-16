//
//  GPXRoot+length.swift
//  OpenGpxTracker
//
//  Created by merlos on 01/10/15.
//  Copyright © 2015 TransitBox. All rights reserved.
//

import Foundation
import MapKit

extension GPXRoot {
    
    //Distance in meters of all the track segments
    public var tracksLength: CLLocationDistance {
        get {
            var tLength: CLLocationDistance = 0.0
            for track in (self.tracks as? [GPXTrack])! {
                tLength += track.length
            }
            return tLength
        }
    }
    
    //public var routesLength: CLLLocationDist {
    //}
}
