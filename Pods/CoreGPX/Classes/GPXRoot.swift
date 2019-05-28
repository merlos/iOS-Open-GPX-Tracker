//
//  GPXRoot.swift
//  GPXKit
//
//  Created by Vincent on 5/11/18.
//  

import Foundation

/**
    Creation of a GPX file or GPX formatted string starts here
 
    `GPXRoot` holds all `metadata`, `waypoints`, `tracks`, `routes` and `extensions` types together before being packaged as a GPX file, or formatted as per GPX schema's requirements.
*/
open class GPXRoot: GPXElement {
    
    /// GPX version that will be generated. Currently, only the latest (version 1.1) is supported.
    public var version: String?
    
    /// Name of the creator of the GPX content.
    ///
    /// Can be your name or your app's name
    public var creator: String?
    
    /// Metadata to be included in your GPX content.
    public var metadata: GPXMetadata?
    
    /// Array of waypoints
    public var waypoints = [GPXWaypoint]()
    
    /// Array of routes
    public var routes = [GPXRoute]()
    
    /// Array of tracks
    public var tracks = [GPXTrack]()
    
    /// Items for extensions to GPX schema (if any)
    ///
    /// leave it as is, if used without modification to GPX schema
    public var extensions: GPXExtensions?
    
    
    
    // MARK: GPX v1.1 Namespaces
    
    /// Link to the GPX v1.1 schema
    let schema = "http://www.topografix.com/GPX/1/1"
    /// Link to the schema locations. If extended, the extended schema should be added.
    let schemaLocation = "http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
    /// Link to XML schema instance
    let xsi = "http://www.w3.org/2001/XMLSchema-instance"
    
    
    
    // MARK:- Public Initializers
    
    /// for initializing without a creator name
    ///
    /// It will initialize with the creator name set to its defaults.
    ///
    public required init() {
        super.init()
        self.creator = "Powered by Open Source CoreGPX Project"
        self.version = "1.1"
    }
    
    /// for initializing with a creator name
    ///
    /// - Parameters:
    ///    - creator: name of your app, or whichever product that ends up generating a GPX file
    ///
    public init(creator: String) {
        super.init()
        self.creator = creator
        self.version = "1.1"
    }
    
    /// For internal use only
    ///
    /// Initializes the metadata using a dictionary, with each key being an attribute name.
    ///
    /// - Remark:
    /// This initializer is designed only for use when parsing GPX files, and shouldn't be used in other ways.
    ///
    /// - Parameters:
    ///     - dictionary: a dictionary with a key of an attribute, followed by the value which is set as the GPX file is parsed.
    ///
    internal init(dictionary: [String : String]) {
        self.creator = dictionary["creator"]
        self.version = dictionary["version"]
    }
    
    
    // MARK:- Public Methods
    
    /// for saving newly tracked data straight to a GPX file in a directory
    ///
    /// - Parameters:
    ///     - location: A `URL` where you wish to have the GPX file saved at.
    ///     - fileName: The name of the file which you wish to save as, without extension.
    ///
    /// - Throws: An error if GPX file fails to write at `location` for whichever reason.
    ///
    public func outputToFile(saveAt location: URL, fileName: String) throws {
        let gpxString = self.gpx()
        let filePath = location.appendingPathComponent("\(fileName).gpx")
        
        do {
            try gpxString.write(to: filePath, atomically: true, encoding: .utf8)
        }
        catch {
            print(error)
            throw error
        }
    }
    
    /// Initializes a new `waypoint` which is also added to `GPXRoot` automatically
    ///
    /// - Parameters:
    ///     - latitude: Waypoint's latitude in `Double` or `CLLocationDegrees`
    ///     - longitude: Waypoint's latitude in `Double` or `CLLocationDegrees`
    ///
    /// A waypoint is initialized with latitude and longitude, then added into the array of waypoints in this `GPXRoot`.
    ///
    /// - Warning:
    /// This method is **not recommended**. It is recommended that you initialize a waypoint first, configure it, and use method `add(waypoint:)` instead.
    ///
    /// - Returns:
    /// A `GPXWaypoint` object.
    ///
    public func newWaypointWith(latitude: Double, longitude: Double) -> GPXWaypoint {
        let waypoint = GPXWaypoint.init(latitude: latitude, longitude: longitude)
        
        self.add(waypoint: waypoint)
        
        return waypoint
    }
    
    /// Add a pre-initialized and configured waypoint to `GPXRoot`
    ///
    /// - Parameters:
    ///     - waypoint: The waypoint that you wish to include in `GPXRoot`
    ///
    public func add(waypoint: GPXWaypoint?) {
        if let validWaypoint = waypoint {
           self.waypoints.append(validWaypoint)
        }
    }
    
    /// Add an array of pre-initialized and configured waypoints to `GPXRoot`
    ///
    /// - Parameters:
    ///     - waypoints: Array of waypoints that you wish to include in `GPXRoot`
    ///
    public func add(waypoints: [GPXWaypoint]) {
        self.waypoints.append(contentsOf: waypoints)
    }
    
    /// Removes an already added waypoint from `GPXRoot`
    ///
    /// - Parameters:
    ///     - waypoint: The waypoint that you wish to remove from `GPXRoot`
    ///
    public func remove(waypoint: GPXWaypoint) {
        let contains = waypoints.contains(waypoint)
        if contains == true {
            waypoint.parent = nil
            if let index = waypoints.firstIndex(of: waypoint) {
                self.waypoints.remove(at: index)
            }
        }
    }
    
    public func remove(WaypointAtIndex index: Int) {
        self.waypoints.remove(at: index)
    }
    
    /// Initializes a new `route` which is also added to `GPXRoot` automatically
    ///
    /// A route is initialized, then added into the array of routes in this `GPXRoot`.
    ///
    /// - Warning:
    /// This method is **not recommended**. It is recommended that you initialize a route first, configure it, and use method `add(route:)` instead.
    ///
    /// - Returns:
    /// A `GPXRoute` object.
    ///
    public func newRoute() -> GPXRoute {
        let route = GPXRoute()
        
        self.add(route: route)
        
        return route
    }
    
    /// Add a pre-initialized and configured route to `GPXRoot`
    ///
    /// - Parameters:
    ///     - route: The route that you wish to include in `GPXRoot`
    ///
    public func add(route: GPXRoute?) {
        if let validRoute = route {
           self.routes.append(validRoute)
        }
    }
    
    /// Add an array of pre-initialized and configured routes to `GPXRoot`
    ///
    /// - Parameters:
    ///     - routes: The array of routes that you wish to include in `GPXRoot`
    ///
    public func add(routes: [GPXRoute]) {
        self.routes.append(contentsOf: routes)
    }
    
    /// Removes an already added waypoint from `GPXRoot`
    ///
    /// - Parameters:
    ///     - route: The route that you wish to remove from `GPXRoot`
    ///
    public func remove(route: GPXRoute) {
        let contains = routes.contains(route)
        if contains == true {
            route.parent = nil
            if let index = routes.firstIndex(of: route) {
                self.waypoints.remove(at: index)
            }
        }
    }
    
    /// Initializes a new `track` which is also added to `GPXRoot` automatically
    ///
    /// A track is initialized, then added into the array of tracks in this `GPXRoot`.
    ///
    /// - Warning:
    /// This method is **not recommended**. It is recommended that you initialize a track first, configure it, and use method `add(track:)` instead.
    ///
    /// - Returns:
    /// A `GPXTrack` object.
    ///
    public func newTrack() -> GPXTrack {
        let track = GPXTrack()
        
        return track
    }
    
    /// Add a pre-initialized and configured track to `GPXRoot`
    ///
    /// - Parameters:
    ///     - track: The track that you wish to include in `GPXRoot`
    ///
    public func add(track: GPXTrack?) {
        if let validTrack = track {
            self.tracks.append(validTrack)
        }
    }
    
    /// Add an array of pre-initialized and configured tracks to `GPXRoot`
    ///
    /// - Parameters:
    ///     - tracks: The array of tracks that you wish to include in `GPXRoot`
    ///
    public func add(tracks: [GPXTrack]) {
        self.tracks.append(contentsOf: tracks)
    }
    
    /// Removes an already added track from `GPXRoot`
    ///
    /// - Parameters:
    ///     - track: The track that you wish to remove from `GPXRoot`
    ///
    public func remove(track: GPXTrack) {
        let contains = tracks.contains(track)
        if contains == true {
            track.parent = nil
            if let index = tracks.firstIndex(of: track) {
               self.waypoints.remove(at: index)
            }
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "gpx"
    }
    
    // MARK:- GPX
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        attribute.appendFormat(" xmlns:xsi=\"%@\"", self.xsi)
        attribute.appendFormat(" xmlns=\"%@\"", self.schema)
        attribute.appendFormat(" xsi:schemaLocation=\"%@\"", self.schemaLocation)
        
        if let version = self.version {
            attribute.appendFormat(" version=\"%@\"", version)
        }
        
        if let creator = self.creator {
            attribute.appendFormat(" creator=\"%@\"", creator)
        }
        
        gpx.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n")
        
        gpx.appendFormat("%@<%@%@>\r\n", self.indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        if self.metadata != nil {
            self.metadata?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for waypoint in waypoints {
            waypoint.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for route in routes {
            route.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for track in tracks {
            track.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
