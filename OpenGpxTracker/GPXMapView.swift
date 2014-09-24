//
//  GPXMapView.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation
import UiKit
import MapKit

//GPX creator identifier
let kGPXCreatorString = "Open GPX Tracker for iOS"

// 
// A mapview that automatically tracks user 
// Can add annotations, annotations 

// is able to convert GPX file into map
// is able to return a GPX file from map

class GPXMapView : MKMapView {
    
    var waypoints : [GPXWaypoint] = []
    var tracks : [GPXTrack] = []
    var trackSegments : [GPXTrackSegment] = []
    var currentSegment: GPXTrackSegment =  GPXTrackSegment()
    var currentSegmentOverlay: MKPolyline //Polyline conforms MKOverlay protocol
    
    
    required init(coder aDecoder: NSCoder) {
        var tmpCoords: [CLLocationCoordinate2D] = [] //init with empty
        self.currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        super.init(coder: aDecoder)

    }
    //point is the a the point in a view where the user touched
    //
    //For example, this function can be used to add a waypoint after long press on the map view
    func addWaypointAtViewPoint(point: CGPoint) {
        let coords = self.convertPoint(point, toCoordinateFromView: self)
        let waypoint = GPXWaypoint(coordinate: coords)
        self.addWaypoint(waypoint)
        
    }
    func addWaypoint(waypoint: GPXWaypoint) {
        self.waypoints.append(waypoint)
        self.addAnnotation(waypoint)
    }
    
    func removeWaypoint(waypoint: GPXWaypoint) {
        let index = find(waypoints, waypoint)
        if index == nil {
            println("Waypoint not found")
            return
        }
        self.removeAnnotation(waypoint)
        waypoints.removeAtIndex(index!)
        
        
    }
    
    
    func addPointToCurrentTrackSegmentAtLocation(location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.currentSegment.addTrackpoint(pt)
        //redrawCurrent track segment overlay
        //First remove last overlay, then re-add the overlay updated with the new point
        self.removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = currentSegment.overlay
        self.addOverlay(currentSegmentOverlay)
    }
    
    func startNewTrackSegment() {
        self.trackSegments.append(self.currentSegment)
        self.currentSegment = GPXTrackSegment()
        self.currentSegmentOverlay = MKPolyline()
    }
    
    func finishCurrentSegment() {
        self.startNewTrackSegment() //basically, we need to append the segment to the list of segments
    }
    
    func clearMap() {
        self.trackSegments = []
        self.tracks = []
        self.currentSegment = GPXTrackSegment()
        self.waypoints = []
        self.removeOverlays(self.overlays)
        self.removeAnnotations(self.annotations)
    }
    
    func exportToGPXString() -> String {
        println("Exporting map data into GPX String")
        //Create the gpx structure
        let gpx = GPXRoot(creator: kGPXCreatorString)
        gpx.addWaypoints(self.waypoints)
        let track = GPXTrack()
        track.addTracksegments(self.trackSegments)
        self.tracks.append(track)
        gpx.addTracks(self.tracks)
        return gpx.gpx()
    }
   
    //TODO
    func getGPXDataExtent() -> MKCoordinateRegion {
        var maxLat: CLLocationDegrees = 0.0
        var minLat: CLLocationDegrees = 0.0
        var maxLon: CLLocationDegrees = 0.0
        var minLon: CLLocationDegrees = 0.0
        
        for waypoint in self.waypoints {
            if waypoint.latitude < CGFloat(minLat) {
                minLat = CLLocationDegrees(waypoint.latitude)
            }
            //if waypoint
        }
        
        let span = MKCoordinateSpan(latitudeDelta: maxLat - minLat, longitudeDelta: maxLon - minLon)
        let centerLat = 0.0
        let centerLon = 0.0
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        let extent = MKCoordinateRegion(center: center, span: span)
        return extent
    }
    
    //sets the map view center so that all the GPX data is displayed
    func setRegionToGPXDataExtent() {
        //TODO
     
        //self.setRegion(extent, animated: true)
    }


    /*
    func importFromGPXString(gpxString: String) {
        // TODO
    }
    */
    
    
    func importFromGPXRoot(gpx: GPXRoot) {
        
        //clear current map
        self.clearMap()
        
        //add waypoints
        self.waypoints = gpx.waypoints as [GPXWaypoint]
        var pt: GPXWaypoint
        for pt in self.waypoints {
            self.addWaypoint(pt)
        }
        //add track segments
        self.tracks = gpx.tracks as [GPXTrack]
        for oneTrack in self.tracks {
            for segment in oneTrack.tracksegments {
                self.addOverlay(segment.overlay)
            }
        }
    }
 
    //private func getMaxMinCoord(one: CLLocationCoordinate2D, two: CLLocationCoordinate2D)
}