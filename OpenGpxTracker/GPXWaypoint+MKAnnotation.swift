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
        //set default title and subtitle
        
        // Default title now
        let timeFormat = DateFormatter()
        timeFormat.dateStyle = DateFormatter.Style.none
        timeFormat.timeStyle = DateFormatter.Style.medium
        //timeFormat.setLocalizedDateFormatFromTemplate("HH:mm:ss")
        
        let subtitleFormat = DateFormatter()
        //dateFormat.setLocalizedDateFormatFromTemplate("MMM dd, yyyy")
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
        set {
            self.name = newValue
        }
        get {
            return self.name
        }
    }
    
    /// Subtitle displayed on the annotation bubble
    /// Description of the GPXWaypoint.
    public var subtitle: String? {
        set {
            self.desc = newValue
        }
        get {
            return self.desc
        }
    }
    
    ///Annotation coordinates. Returns/Sets the waypoint latitude and longitudes.
    public var coordinate: CLLocationCoordinate2D {
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: self.latitude!, longitude: CLLocationDegrees(self.longitude!))
        }
    }    
}
