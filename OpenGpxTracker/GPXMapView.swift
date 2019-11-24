//
//  GPXMapView.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//


import Foundation
import UIKit
import MapKit
import CoreLocation
import CoreGPX
import CoreData
import MapCache

///
/// A MapView that Tracks user position
///
/// - it is able to convert GPX file into map
/// - it is able to return a GPX file from map
///
///
/// ### Some definitions
///
/// 1. A **track** is a set of segments.
/// 2. A **segment** is set of points. A segment is linked to a MKPolyline overlay in the map.

/// Each time the user touches "Start Tracking" => a segment is created (currentSegment)
/// Each time the users touches "Pause Tracking" => the segment is added to trackSegments
/// When the user saves the file => trackSegments are consolidated in a single track that is
/// added to the file.
/// If the user opens the file in a session for the second, then tracks some seg ments and saves
/// the file again, the resulting gpx file will have two tracks.
///

class GPXMapView: MKMapView {
    
    /// Current session of GPX location logging. Handles all background tasks and recording.
    let session = GPXSession()

    /// The line being displayed on the map that corresponds to the current segment.
    var currentSegmentOverlay: MKPolyline
    
    ///
    var extent: GPXExtentCoordinates = GPXExtentCoordinates() //extent of the GPX points and tracks

    ///position of the compass in the map
    ///Example:
    /// map.compassRect = CGRect(x: map.frame.width/2 - 18, y: 70, width: 36, height: 36)
    var compassRect : CGRect
    
    /// Is the map using local image cache??
    var useCache: Bool = true { //use tile overlay cache (
        didSet {
            if self.tileServerOverlay is CachedTileOverlay {
                print("GPXMapView:: setting useCache \(self.useCache)")
                (self.tileServerOverlay as! CachedTileOverlay).useCache = self.useCache
            }
        }
    }
    
    ///
    /// Returns current zoom level
    ///
    public var zoomLevel2: Int {
        // function returns current zoom of the map
          var angleCamera = self.camera.heading
          if angleCamera > 270 {
              angleCamera = 360 - angleCamera
          } else if angleCamera > 90 {
              angleCamera = fabs(angleCamera - 180)
          }
        print(camera)
        let angleRad = Double.pi * angleCamera / 180 // camera heading in radians
          let width = Double(self.frame.size.width)
          let height = Double(self.frame.size.height)
          let heightOffset : Double = 0 // the offset (status bar height) which is taken by MapKit into consideration to calculate visible area height
          // calculating Longitude span corresponding to normal (non-rotated) width
          let spanStraight = width * self.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return Int(log2(360 * ((width / 256) / spanStraight)) + 1.0);
    }
    
    /// Arrow image to display heading (orientation of the device)
    /// initialized on MapViewDelegate
    var headingImageView: UIImageView?
    
    /// Selected tile server.
    /// - SeeAlso: GPXTileServer
    var tileServer: GPXTileServer = .apple {
        willSet {
            print("Setting map tiles overlay to: \(newValue.name)" )
            // remove current overlay
            if self.tileServer != .apple {
                //to see apple maps we need to remove the overlay added by map cache.
                self.removeOverlay(self.tileServerOverlay)
            }
            
            /// Min distance to the floor of the camera
            if #available(iOS 13, *) {
             self.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: newValue.minCameraDistance, maxCenterCoordinateDistance: -1), animated: true)
            }
            
            //add new overlay to map if not using Apple Maps
            if newValue == .apple {
                if #available(iOS 13, *) {
                    overrideUserInterfaceStyle = .unspecified
                    NotificationCenter.default.post(name: .updateAppearance, object: nil, userInfo: nil)
                }
                
            } else {
                // if map is third party, dark mode is disabled.
                if #available(iOS 13, *) {
                    overrideUserInterfaceStyle = .light
                    NotificationCenter.default.post(name: .updateAppearance, object: nil, userInfo: nil)
                }
                //Update cacheConfig
                var config = MapCacheConfig(withUrlTemplate: newValue.templateUrl)
                config.subdomains = newValue.subdomains
                
                if newValue.maximumZ > 0 {
                    config.maximumZ = newValue.maximumZ
                }
                if newValue.minimumZ > 0  {
                    config.minimumZ = newValue.minimumZ
                }
                let cache = MapCache(withConfig: config)
                // the overlay returned substitutes Apple Maps tile overlay.
                // we need to keep a reference to remove it, in case we return back to Apple Maps.
                self.tileServerOverlay = useCache(cache)
            }
        }
    }
    
    /// Overlay that holds map tiles
    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
    
    ///
    let coreDataHelper = CoreDataHelper()
    
    /// Heading of device
    var heading: CLHeading?
    
    /// Offset to heading due to user's map rotation
    var headingOffset: CGFloat?
    
    /// Gesture for heading arrow to be updated in realtime during user's map interactions
    var rotationGesture = UIRotationGestureRecognizer()
    
    ///
    /// Initializes the map with an empty currentSegmentOverlay.
    ///
    required init?(coder aDecoder: NSCoder) {
        var tmpCoords: [CLLocationCoordinate2D] = [] //init with empty
        self.currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        self.compassRect = CGRect.init(x: 0, y: 0, width: 36, height: 36)
        super.init(coder: aDecoder)
        
        // Rotation Gesture handling (for the map rotation's influence towards heading pointing arrow)
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureHandling(_:)))
        
        self.addGestureRecognizer(rotationGesture)
        self.isUserInteractionEnabled = true
        self.isMultipleTouchEnabled = true
    }
    
    ///
    /// Override default implementation to set the compass that appears in the map in a better position.
    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        // set compass position by setting its frame
        if let compassView = self.subviews.filter({ $0.isKind(of:NSClassFromString("MKCompassView")!) }).first {
            if compassRect.origin.x != 0 {
                compassView.frame = compassRect
            }
        }
    }
    
    /// Handles rotation detected from user, for heading arrow to update.
    @objc func rotationGestureHandling(_ gesture: UIRotationGestureRecognizer) {
        self.headingOffset = gesture.rotation
        self.updateHeading()
        
        if gesture.state == .ended {
            self.headingOffset = nil
        }
    }
    
    ///
    /// Adds a waypoint annotation in the point passed as arguments
    ///
    /// For example, this function can be used to add a waypoint after long press on the map view
    ///
    /// - Parameters:
    ///     - point: The location in which the waypoint has to be added.
    ///
    func addWaypointAtViewPoint(_ point: CGPoint) {
        let coords: CLLocationCoordinate2D = self.convert(point, toCoordinateFrom: self)
        let waypoint = GPXWaypoint(coordinate: coords)
        self.addWaypoint(waypoint)
        self.coreDataHelper.add(toCoreData: waypoint)
        
    }
    
    ///
    /// Adds a waypoint to the map.
    ///
    /// - Parameters: The waypoint to add to the map.
    ///
    func addWaypoint(_ waypoint: GPXWaypoint) {
    	self.session.addWaypoint(waypoint)
        self.addAnnotation(waypoint)
        self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
    }
    
    ///
    /// Removes a Waypoint from the map
    ///
    /// - Parameters: The waypoint to remove from the map.
    ///
    func removeWaypoint(_ waypoint: GPXWaypoint) {
        let index = session.waypoints.firstIndex(of: waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        } 
        self.removeAnnotation(waypoint)
        self.session.waypoints.remove(at: index!)
        self.coreDataHelper.deleteWaypoint(fromCoreDataAt: index!)
        //TODO: update map extent?
        
    }
    
    ///
    /// Updates the heading arrow based on the heading information
    ///
    func updateHeading() {
        guard let heading = self.heading else { return }
        
        headingImageView?.isHidden = false
        let rotation = CGFloat((heading.trueHeading - camera.heading)/180 * Double.pi)
        
        var newRotation = rotation
        
        if let headingOffset = headingOffset {
            newRotation = rotation + headingOffset
        }
 
        UIView.animate(withDuration: 0.15) {
            self.headingImageView?.transform = CGAffineTransform(rotationAngle: newRotation)
        }
    }
    
    ///
    /// Adds a new point to current segment.
    /// - Parameters:
    ///    - location: Typically a location provided by CLLocation
    ///
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
    let pt = GPXTrackPoint(location: location)
        self.coreDataHelper.add(toCoreData: pt, withTrackSegmentID: session.trackSegments.count)
        self.session.addPointToCurrentTrackSegmentAtLocation(location)
        //redrawCurrent track segment overlay
        //First remove last overlay, then re-add the overlay updated with the new point
        self.removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = self.session.currentSegment.overlay
        self.addOverlay(currentSegmentOverlay)
        self.extent.extendAreaToIncludeLocation(location.coordinate)
    }
    
    ///
    /// If current segmet has points, it appends currentSegment to trackSegments and
    /// initializes currentSegment to a new one.
    ///
    func startNewTrackSegment() {
        if self.session.currentSegment.trackpoints.count > 0 {
            self.session.startNewTrackSegment()
            self.currentSegmentOverlay = MKPolyline()
        }
    }
    
    ///
    /// Finishes current segment.
    ///
    func finishCurrentSegment() {
        self.startNewTrackSegment() //basically, we need to append the segment to the list of segments
    }
    
    ///
    /// Clears map.
    ///
    func clearMap() {
        self.session.reset()
        self.removeOverlays(self.overlays)
        self.removeAnnotations(self.annotations)
        self.extent = GPXExtentCoordinates()
        
        //add tile server overlay
        //by removing all overlays, tile server overlay is also removed. We need to add it back
        if tileServer != .apple {
            self.addOverlay(tileServerOverlay, level: .aboveLabels)
        }
    }
    
    ///
    ///
    /// Converts current map into a GPX String
    ///
    ///
    func exportToGPXString() -> String {
        return self.session.exportToGPXString()
    }
   
    ///
    /// Sets the map region to display all the GPX data in the map (segments and waypoints).
    ///
    func regionToGPXExtent() {
        self.setRegion(extent.region, animated: true)
    }


    /*
    func importFromGPXString(gpxString: String) {
        // TODO
    }
    */
    
    /// Imports GPX contents into the map.
    ///
    /// - Parameters:
    ///     - gpx: The result of loading a gpx file with iOS-GPX-Framework.
    ///
    func importFromGPXRoot(_ gpx: GPXRoot) {
        //clear current map
        self.clearMap()
        //add waypoints
        for pt in gpx.waypoints {
            self.addWaypoint(pt)
            self.coreDataHelper.add(toCoreData: pt)
        }
        //add track segments
        self.session.tracks = gpx.tracks
        for oneTrack in self.session.tracks {
            self.session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                self.addOverlay(overlay)
                let segmentTrackpoints = segment.trackpoints
                //add point to map extent
                for waypoint in segmentTrackpoints {
                    self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
        //clear current map
        self.clearMap()
        
        for pt in gpx.waypoints {
            self.addWaypoint(pt)
        }
        
        self.session.continueFromGPXRoot(gpx)
        
        // for last session's previous tracks, through resuming
        for oneTrack in self.session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                self.addOverlay(overlay)
                
                let segmentTrackpoints = segment.trackpoints
                //add point to map extent
                for waypoint in segmentTrackpoints {
                    self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
        
        // for last session track segment
        for trackSegment in self.session.trackSegments {
            
            let overlay = trackSegment.overlay
            self.addOverlay(overlay)
            
            let segmentTrackpoints = trackSegment.trackpoints
            //add point to map extent
            for waypoint in segmentTrackpoints {
                self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
            }
        }
        
    }
}

