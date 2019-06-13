//
//  GPXSession.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 13/6/19.
//

import Foundation
import CoreGPX
import CoreLocation

#if os(iOS)
/// GPX creator identifier. Used on generated files identify this app created them.
let kGPXCreatorString = "Open GPX Tracker for iOS"

#elseif os(watchOS)
/// GPX creator identifier. Used on generated files identify this app created them.
let kGPXCreatorString = "Open GPX Tracker for watchOS"
typealias GPXMapView = GPXSession
#endif

class GPXSession {
    
    /// List of waypoints currently displayed on the map.
    var waypoints: [GPXWaypoint] = []
    
    /// List of tracks currently displayed on the map.
    var tracks: [GPXTrack] = []
    
    /// Current track segments
    var trackSegments: [GPXTrackSegment] = []
    
    /// Segment in which device locations are added.
    var currentSegment: GPXTrackSegment =  GPXTrackSegment()
    
    ///
    var extent: GPXExtentCoordinates = GPXExtentCoordinates() //extent of the GPX points and tracks
    
    /// Total tracked distance in meters
    var totalTrackedDistance = 0.00
    
    /// Distance in meters of current track (track in which new user positions are being added)
    var currentTrackDistance = 0.00
    
    /// Current segment distance in meters
    var currentSegmentDistance = 0.00
    
    
    ///
    /// Adds a waypoint to the map.
    ///
    /// - Parameters: The waypoint to add to the map.
    ///
    func addWaypoint(_ waypoint: GPXWaypoint) {
        self.waypoints.append(waypoint)
        //self.addAnnotation(waypoint)
        self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
    }
    
    ///
    /// Removes a Waypoint from the map
    ///
    /// - Parameters: The waypoint to remove from the map.
    ///
    func removeWaypoint(_ waypoint: GPXWaypoint) {
        let index = waypoints.index(of: waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        }
        waypoints.remove(at: index!)
    }
    
    ///
    /// Adds a new point to current segment.
    /// - Parameters:
    ///    - location: Typically a location provided by CLLocation
    ///
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.currentSegment.add(trackpoint: pt)
        //self.extent.extendAreaToIncludeLocation(location.coordinate)
        if #available(watchOS 2, *) {
            incrementDistanceAtLocation(location)
        }
    }
    
    func incrementDistanceAtLocation(_ location: CLLocation) {

        //add the distance to previous tracked point
        if self.currentSegment.trackpoints.count >= 2 { //at elast there are two points in the segment
            let prevPt = self.currentSegment.trackpoints[self.currentSegment.trackpoints.count-2] //get previous point
            guard let latitude = prevPt.latitude, let longitude = prevPt.longitude else { return }
            let prevPtLoc = CLLocation(latitude: latitude, longitude: longitude)
            //now get the distance
            let distance = prevPtLoc.distance(from: location)
            self.currentTrackDistance += distance
            self.totalTrackedDistance += distance
            self.currentSegmentDistance += distance
        }
    }
    
    
    ///
    /// Appends currentSegment to trackSegments and initializes currentSegment to a new one.
    ///
    func startNewTrackSegment() {
        if self.currentSegment.trackpoints.count > 0 {
            self.trackSegments.append(self.currentSegment)
            self.currentSegment = GPXTrackSegment()
            self.currentSegmentDistance = 0.00
        }
    }
    
    ///
    /// Clears map.
    ///
    func clearMap() {
        self.trackSegments = []
        self.tracks = []
        self.currentSegment = GPXTrackSegment()
        self.waypoints = []
        self.extent = GPXExtentCoordinates()
        
        self.totalTrackedDistance = 0.00
        self.currentTrackDistance = 0.00
        self.currentSegmentDistance = 0.00
        
    }
    
    ///
    ///
    /// Converts current map into a GPX String
    ///
    ///
    func exportToGPXString() -> String {
        print("Exporting map data into GPX String")
        //Create the gpx structure
        let gpx = GPXRoot(creator: kGPXCreatorString)
        gpx.add(waypoints: self.waypoints)
        let track = GPXTrack()
        track.add(trackSegments: self.trackSegments)
        //add current segment if not empty
        if self.currentSegment.trackpoints.count > 0 {
            track.add(trackSegment: self.currentSegment)
        }
        //add existing tracks
        gpx.add(tracks: self.tracks)
        //add current track
        gpx.add(track: track)
        return gpx.gpx()
    }
    
}
