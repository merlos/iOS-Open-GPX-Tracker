//
//  GPXPoint+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//

import Foundation
import UIKit
import MapKit
import CoreGPX

/// Extends the GPXTrackPoint to be able to be initialized with a `CLLocation` object.
extension GPXTrackPoint {

    /// Initializes a trackpoint with the CLLocation data
    convenience init(location: CLLocation) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.time = Date()
        self.elevation = location.altitude
    }
}
