//
//  GPXRoot+length.swift
//  OpenGpxTracker
//
//  Created by merlos on 01/10/15.
//

import Foundation
import MapKit
import GPXKit

/// Extends GPXRoot to support getting the length of all tracks in meters
extension GPXRoot {
    
    ///Distance in meters of all the track segments
    public var tracksLength: CLLocationDistance {
        get {
            var tLength: CLLocationDistance = 0.0
            for track in (self.tracks as? [GPXTrack])! {
                tLength += track.length
            }
            return tLength
        }
    }
}
