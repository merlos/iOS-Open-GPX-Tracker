//
//  GPXPin.swift
//  OpenGpxTracker
//
//  Created by merlos on 16/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension GPXWaypoint : MKAnnotation {
    

    convenience init (coordinate:CLLocationCoordinate2D) {
       
        self.init(latitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        //set default title and subtitle
        // Default title now
        
        let timeFormat = NSDateFormatter()
        timeFormat.setLocalizedDateFormatFromTemplate("HH:mm:ss")
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("MMM dd, yyyy")
        let now = NSDate()
        self.time = now
        self.title = timeFormat.stringFromDate(now)
        self.subtitle = dateFormat.stringFromDate(now)
    }
    
    public var title:String! {
        set {
            self.name = newValue
        }
        get {
            return self.name
        }
    }
    
    public var subtitle:String! {
        set{
            self.desc = newValue
        }
        get {
            return self.desc
        }
    }
    
    public var coordinate: CLLocationCoordinate2D {
        set {
            self.latitude = CGFloat(newValue.latitude)
            self.longitude = CGFloat(newValue.longitude)
        }
        get {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(self.latitude), longitude: CLLocationDegrees(self.longitude))
        }
    }
    
    public func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coordinate = newCoordinate
    }
}