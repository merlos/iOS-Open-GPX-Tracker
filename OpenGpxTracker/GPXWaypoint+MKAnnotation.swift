//
//  GPXPin.swift
//  OpenGpxTracker
//
//  Created by merlos on 16/09/14.
//

import Foundation
import MapKit
import CoreGPX

///
/// Extends GPXWaypoint to support the MKAnnotation protocol. It allows to
/// add the waypoint as a pin in the map
///
extension GPXWaypoint: MKAnnotation {
    
    ///
    /// Inits the point with a coordinate
    ///
    convenience init (coordinate: CLLocationCoordinate2D) { 
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // Set default title and subtitle
        
        // Default title now
        let timeFormat = DateFormatter()
        timeFormat.dateStyle = DateFormatter.Style.none
        timeFormat.timeStyle = DateFormatter.Style.medium
        
        let subtitleFormat = DateFormatter()
        subtitleFormat.dateStyle = DateFormatter.Style.medium
        subtitleFormat.timeStyle = DateFormatter.Style.medium
        
        let now = Date()
        self.time = now
        self.title = timeFormat.string(from: now)
        self.subtitle = subtitleFormat.string(from: now)
    }
    
    convenience init (coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance?) {
        self.init(coordinate: coordinate)
        self.elevation = altitude
    }
    
    /// Title displayed on the annotation bubble.
    /// Is the attribute name of the waypoint.
    public var title: String? {
        get {
            return self.name
        }
        set {
            self.name = newValue
        }
        
    }
    
    /// Subtitle displayed on the annotation bubble
    /// Description of the GPXWaypoint.
    public var subtitle: String? {
        get {
            return self.desc
        }
        set {
            self.desc = newValue
        }

    }
    
    /// Annotation coordinates. Returns/Sets the waypoint latitude and longitudes.
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: self.latitude!, longitude: CLLocationDegrees(self.longitude!))
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }    
}
