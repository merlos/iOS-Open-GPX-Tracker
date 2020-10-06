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
    var compassRect: CGRect
    
    /// Is the map using local image cache??
    var useCache: Bool = true { //use tile overlay cache (
        didSet {
            if tileServerOverlay is CachedTileOverlay {
                print("GPXMapView:: setting useCache \(useCache)")
                // swiftlint:disable force_cast
                (tileServerOverlay as! CachedTileOverlay).useCache = useCache
            }
        }
    }
    
    /// Arrow image to display heading (orientation of the device)
    /// initialized on MapViewDelegate
    var headingImageView: UIImageView?
    
    /// Selected tile server.
    /// - SeeAlso: GPXTileServer
    var tileServer: GPXTileServer = .apple {
        willSet {
            print("Setting map tiles overlay to: \(newValue.name)" )
            updateMapInformation(newValue)
            // remove current overlay
            if tileServer != .apple {
                //to see apple maps we need to remove the overlay added by map cache.
                removeOverlay(tileServerOverlay)
            }
            
            //add new overlay to map if not using Apple Maps
            if newValue != .apple {
                //Update cacheConfig
                var config = MapCacheConfig(withUrlTemplate: newValue.templateUrl)
                config.subdomains = newValue.subdomains
                config.tileSize = CGSize(width: newValue.tileSize, height: newValue.tileSize)
                if newValue.maximumZ > 0 {
                    config.maximumZ = newValue.maximumZ
                }
                if newValue.minimumZ > 0 {
                    config.minimumZ = newValue.minimumZ
                }
                let cache = MapCache(withConfig: config)
                // the overlay returned substitutes Apple Maps tile overlay.
                // we need to keep a reference to remove it, in case we return back to Apple Maps.
                tileServerOverlay = useCache(cache)
            }
        }
        didSet {
            if #available(iOS 13, *) {
                if tileServer == .apple {
                    overrideUserInterfaceStyle = .unspecified
                    NotificationCenter.default.post(name: .updateAppearance, object: nil, userInfo: nil)
                } else { // if map is third party, dark mode is disabled.
                    overrideUserInterfaceStyle = .light
                    NotificationCenter.default.post(name: .updateAppearance, object: nil, userInfo: nil)
                }
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
        currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        compassRect = CGRect.init(x: 0, y: 0, width: 36, height: 36)
        super.init(coder: aDecoder)
        
        // Rotation Gesture handling (for the map rotation's influence towards heading pointing arrow)
        rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationGestureHandling(_:)))
        
        addGestureRecognizer(rotationGesture)
        isUserInteractionEnabled = true
        isMultipleTouchEnabled = true
    }
    
    ///
    /// Override default implementation to set the compass that appears in the map in a better position.
    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        // set compass position by setting its frame
        if let compassView = subviews.filter({ $0.isKind(of: NSClassFromString("MKCompassView")!) }).first {
            if compassRect.origin.x != 0 {
                compassView.frame = compassRect
            }
        }
        
        updateMapInformation(tileServer)
    }
    
    /// hides apple maps stuff when map tile != apple.
    func updateMapInformation(_ tileServer: GPXTileServer) {
        if let logoClass = NSClassFromString("MKAppleLogoImageView"),
           let mapLogo = subviews.filter({ $0.isKind(of: logoClass) }).first {
            mapLogo.isHidden = (tileServer != .apple)
        }
        
        if let textClass = NSClassFromString("MKAttributionLabel"),
           let mapText = subviews.filter({ $0.isKind(of: textClass) }).first {
            mapText.isHidden = (tileServer != .apple)
        }
    }
    
    /// Handles rotation detected from user, for heading arrow to update.
    @objc func rotationGestureHandling(_ gesture: UIRotationGestureRecognizer) {
        headingOffset = gesture.rotation
        updateHeading()
        
        if gesture.state == .ended {
            headingOffset = nil
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
        let coords: CLLocationCoordinate2D = convert(point, toCoordinateFrom: self)
        let waypoint = GPXWaypoint(coordinate: coords)
        addWaypoint(waypoint)
        coreDataHelper.add(toCoreData: waypoint)
        
    }
    
    ///
    /// Adds a waypoint to the map.
    ///
    /// - Parameters: The waypoint to add to the map.
    ///
    func addWaypoint(_ waypoint: GPXWaypoint) {
    	session.addWaypoint(waypoint)
        addAnnotation(waypoint)
        extent.extendAreaToIncludeLocation(waypoint.coordinate)
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
        removeAnnotation(waypoint)
        session.waypoints.remove(at: index!)
        coreDataHelper.deleteWaypoint(fromCoreDataAt: index!)
    }
    
    ///
    /// Updates the heading arrow based on the heading information
    ///
    func updateHeading() {
        guard let heading = heading else { return }
        
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
        coreDataHelper.add(toCoreData: pt, withTrackSegmentID: session.trackSegments.count)
        session.addPointToCurrentTrackSegmentAtLocation(location)
        //redrawCurrent track segment overlay
        //First remove last overlay, then re-add the overlay updated with the new point
        removeOverlay(currentSegmentOverlay)
        currentSegmentOverlay = session.currentSegment.overlay
        addOverlay(currentSegmentOverlay)
        extent.extendAreaToIncludeLocation(location.coordinate)
    }
    
    ///
    /// If current segmet has points, it appends currentSegment to trackSegments and
    /// initializes currentSegment to a new one.
    ///
    func startNewTrackSegment() {
        if session.currentSegment.trackpoints.count > 0 {
            session.startNewTrackSegment()
            currentSegmentOverlay = MKPolyline()
        }
    }
    
    ///
    /// Finishes current segment.
    ///
    func finishCurrentSegment() {
        startNewTrackSegment() //basically, we need to append the segment to the list of segments
    }
    
    ///
    /// Clears map.
    ///
    func clearMap() {
        session.reset()
        removeOverlays(overlays)
        removeAnnotations(annotations)
        extent = GPXExtentCoordinates()
        
        //add tile server overlay
        //by removing all overlays, tile server overlay is also removed. We need to add it back
        if tileServer != .apple {
            addOverlay(tileServerOverlay, level: .aboveLabels)
        }
    }
    
    ///
    ///
    /// Converts current map into a GPX String
    ///
    ///
    func exportToGPXString() -> String {
        return session.exportToGPXString()
    }
   
    ///
    /// Sets the map region to display all the GPX data in the map (segments and waypoints).
    ///
    func regionToGPXExtent() {
        setRegion(extent.region, animated: true)
    }
    
    /// Imports GPX contents into the map.
    ///
    /// - Parameters:
    ///     - gpx: The result of loading a gpx file with iOS-GPX-Framework.
    ///
    func importFromGPXRoot(_ gpx: GPXRoot) {
        clearMap()
        addWaypoints(for: gpx)
        addTrackSegments(for: gpx)
    }

    private func addWaypoints(for gpx: GPXRoot, fromImport: Bool = true) {
        for waypoint in gpx.waypoints {
            addWaypoint(waypoint)
            if fromImport {
                coreDataHelper.add(toCoreData: waypoint)
            }
        }
    }

    private func addTrackSegments(for gpx: GPXRoot) {
        session.tracks = gpx.tracks
        for oneTrack in session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                addOverlay(overlay)
                let segmentTrackpoints = segment.trackpoints
                //add point to map extent
                for waypoint in segmentTrackpoints {
                    extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
    }
    
    func continueFromGPXRoot(_ gpx: GPXRoot) {
        clearMap()
        addWaypoints(for: gpx, fromImport: false)
        
        session.continueFromGPXRoot(gpx)
        
        // for last session's previous tracks, through resuming
        for oneTrack in session.tracks {
            session.totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                addOverlay(overlay)
                
                let segmentTrackpoints = segment.trackpoints
                //add point to map extent
                for waypoint in segmentTrackpoints {
                    extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
        
        // for last session track segment
        for trackSegment in session.trackSegments {
            
            let overlay = trackSegment.overlay
            addOverlay(overlay)
            
            let segmentTrackpoints = trackSegment.trackpoints
            //add point to map extent
            for waypoint in segmentTrackpoints {
                extent.extendAreaToIncludeLocation(waypoint.coordinate)
            }
        }
        
    }
}
