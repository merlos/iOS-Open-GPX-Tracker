//
//  GPXMapView.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//GPX creator identifier
let kGPXCreatorString = "Open GPX Tracker for iOS"

// 
// A mapview that automatically tracks user 
// Can add annotations, annotations 

// is able to convert GPX file into map
// is able to return a GPX file from map

//
// How GPX tracking is
// ------------------------
// A track is a set of segments.
// A segment is set of points (linked with a line/Polyline overlay in the map)
// Each time the user touches "Start Tracking" => a segment is created (currentSegment)
// Each time the users touches "Pause Tracking" => the segment is added to trackSegments
// When the user saves the file => trackSegments are consolidated in a single track that is
// added to the file.
// If the user opens the file in a session for the second, then tracks some segments and saves
// the file again, the resulting gpx file will have two tracks.
//

class GPXMapView: MKMapView {
    
    var waypoints: [GPXWaypoint] = []
    var tracks: [GPXTrack] = []
    var trackSegments: [GPXTrackSegment] = []
    var currentSegment: GPXTrackSegment =  GPXTrackSegment()
    var currentSegmentOverlay: MKPolyline //Polyline conforms MKOverlay protocol
    var extent: GPXExtentCoordinates = GPXExtentCoordinates() //extent of the GPX points and tracks
    
    var totalTrackedDistance = 0.00 // in meters
    var currentTrackDistance = 0.00 // in meters
    var currentSegmentDistance = 0.00 //in meters
    
    var tileServer: GPXTileServer = .MapQuest {
        willSet {
            // Info about how to use other tile servers:
            //http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/
            //Note: it requires to set in the delegate of the mapview a couple of lines
            //
            //Note 2: it seems that there are issues when loading tile images
            //https://github.com/mapbox/mbxmapkit/issues/132
            
            NSLog("Setting map tiles overlay to: \(newValue.name)" )
            
            // remove current overlay
            if self.tileServer != .Apple {
                //remove current overlay
                self.removeOverlay(self.tileServerOverlay)
            }
            //add new overlay to map
            if newValue != .Apple {
                self.tileServerOverlay = MKTileOverlay(URLTemplate: newValue.templateUrl)
                tileServerOverlay.canReplaceMapContent = true
                self.addOverlay(tileServerOverlay, level: .AboveLabels)
            }
        }
    }
    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
    
    required init?(coder aDecoder: NSCoder) {
        var tmpCoords: [CLLocationCoordinate2D] = [] //init with empty
        self.currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        super.init(coder: aDecoder)
    }
    
    func centerAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        setRegion(region, animated: true)
    }
    
    //point is the a the point in a view where the user touched
    //
    //For example, this function can be used to add a waypoint after long press on the map view
    func addWaypointAtViewPoint(point: CGPoint) {
        let coords: CLLocationCoordinate2D = self.convertPoint(point, toCoordinateFromView: self)
        let waypoint = GPXWaypoint(coordinate: coords)
        self.addWaypoint(waypoint)
        
    }
    func addWaypoint(waypoint: GPXWaypoint) {
        self.waypoints.append(waypoint)
        self.addAnnotation(waypoint)
        self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
    }
    
    func removeWaypoint(waypoint: GPXWaypoint) {
        let index = waypoints.indexOf(waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        }
        self.removeAnnotation(waypoint)
        waypoints.removeAtIndex(index!)
        //TODO: update map extent?
        
    }
    
    
    func addPointToCurrentTrackSegmentAtLocation(location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.currentSegment.addTrackpoint(pt)
        //redrawCurrent track segment overlay
        //First remove last overlay, then re-add the overlay updated with the new point
        self.removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = currentSegment.overlay
        self.addOverlay(currentSegmentOverlay)
        self.extent.extendAreaToIncludeLocation(location.coordinate)
        
        //add the distance to previous tracked point
        if self.currentSegment.trackpoints.count >= 2 { //at elast there are two points in the segment
            let prevPt = self.currentSegment.trackpoints[self.currentSegment.trackpoints.count-2] //get previous point
            let prevPtLoc = CLLocation(latitude: Double(prevPt.latitude), longitude: Double(prevPt.longitude))
            //now get the distance
            let distance = prevPtLoc.distanceFromLocation(location)
            self.currentTrackDistance += distance
            self.totalTrackedDistance += distance
            self.currentSegmentDistance += distance
        }
    }
    
    func startNewTrackSegment() {
        self.trackSegments.append(self.currentSegment)
        self.currentSegment = GPXTrackSegment()
        self.currentSegmentOverlay = MKPolyline()
        self.currentSegmentDistance = 0.00
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
        self.extent = GPXExtentCoordinates()
        
        self.totalTrackedDistance = 0.00
        self.currentTrackDistance = 0.00
        self.currentSegmentDistance = 0.00
        
        //add tile server overlay
        //by removing all overlays, tile server overlay is also removed. We need to add it back
        if tileServer != .Apple {
            self.addOverlay(tileServerOverlay, level: .AboveLabels)
        }
        
    }
    
    
    func exportToGPXString() -> String {
        print("Exporting map data into GPX String")
        //Create the gpx structure
        let gpx = GPXRoot(creator: kGPXCreatorString)
        gpx.addWaypoints(self.waypoints)
        let track = GPXTrack()
        track.addTracksegments(self.trackSegments)
        //add current segment if not empty
        if self.currentSegment.trackpoints.count > 0 {
            track.addTracksegment(self.currentSegment)
        }
        self.tracks.append(track)
        gpx.addTracks(self.tracks)
        return gpx.gpx()
    }
   
    //sets the map view center so that all the GPX data is displayed
    func regionToGPXExtent() {
        self.setRegion(extent.region, animated: true)
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
        if let waypoints = gpx.waypoints as? [GPXWaypoint] {
            self.waypoints = waypoints
        }
        for pt in self.waypoints {
            self.addWaypoint(pt)
        }

        //add track segments
        if let tracks = gpx.tracks as? [GPXTrack] {
            self.tracks = tracks
        }
        
        for oneTrack in self.tracks {
            totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                self.addOverlay(segment.overlay)
                if let segmentTrackpoints = segment.trackpoints as? [GPXTrackPoint] {
                    //add point to map extent
                    for waypoint in segmentTrackpoints {
                        self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
                    }
                }
            }
        }
    }
}
