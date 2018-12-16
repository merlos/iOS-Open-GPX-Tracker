//
//  GPXPoint+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//


import Foundation
import UIKit
import MapKit
import GPXKit


extension GPXTrackPoint {

    convenience init(location: CLLocation) {
        self.init()
        self.latitude = CGFloat(location.coordinate.latitude)
        self.longitude = CGFloat(location.coordinate.longitude)
        self.time = Date()
        self.elevation = CGFloat(location.altitude)
    }
    
    
}
