//
//  GPXRoot.swift
//  GPXKit
//
//  Created by Vincent on 5/11/18.
//  

import UIKit

open class GPXRoot: GPXElement {

    //var schema = String()
    public var version: String?
    public var creator: String?
    public var metadata: GPXMetadata?
    public var waypoints = NSMutableArray()
    public var routes = NSMutableArray()
    public var tracks = NSMutableArray()
    public var extensions: GPXExtensions?
    
    // MARK:- Instance
    
    public required init() {
        super.init()
        
        version = "1.1"
        creator = "OSS Project"
        
    }
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
        
        version = value(ofAttribute: "version", xmlElement: element, required: true) ?? ""
        creator = value(ofAttribute: "creator", xmlElement: element, required: true) ?? ""
        
        metadata = childElement(ofClass: GPXMetadata.self, xmlElement: element) as? GPXMetadata
        
        self.childElement(ofClass: GPXWaypoint.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.waypoints.add(element!)
            } })
        
        self.childElement(ofClass: GPXRoute.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.routes.add(element!)
            } })
        
        self.childElement(ofClass: GPXTrack.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.tracks.add(element!)
            } })
        
        extensions = childElement(ofClass: GPXExtensions.self, xmlElement: element) as! GPXExtensions?
        
    }
    
    public init(creator: String) {
        super.init()
        self.creator = creator
    }
    
    // MARK:- Public Methods
    
    public var schema: String? {
        return "http://www.topografix.com/GPX/1/1"
    }
    
    public func newWaypointWith(latitude: CGFloat, longitude: CGFloat) -> GPXWaypoint {
        //let waypoint = GPXWaypoint().waypoint(With: latitude, longitude: longitude)
        let waypoint = GPXWaypoint.init(latitude: latitude, longitude: longitude)
        
        self.add(waypoint: waypoint)
        
        return waypoint
    }
    
    public func add(waypoint: GPXWaypoint?) {
        if waypoint != nil {
            let index: Int = waypoints.index(of: waypoint!)
            
            if index == NSNotFound {
                waypoint?.parent = self
                waypoints.add(waypoint!)
            }
        }
    }
    
    public func add(waypoints: [GPXWaypoint]) {
        for waypoint in waypoints {
            self.add(waypoint: waypoint)
        }
    }
    
    public func remove(waypoint: GPXWaypoint) {
        let index = waypoints.index(of: waypoint)
        
        if index != NSNotFound {
            waypoint.parent = nil
            waypoints.remove(waypoint)
        }
    }
    
    public func newRoute() -> GPXRoute {
        let route = GPXRoute()
        
        self.add(route: route)
        
        return route
    }
    
    public func add(route: GPXRoute?) {
        if route != nil {
            let index = routes.index(of: route!)
            if index == NSNotFound {
                route?.parent = self
                routes.add(route!)
            }
        }
    }
    
    public func add(routes: [GPXRoute]) {
        for route in routes {
            self.add(route: route)
        }
    }
    
    public func remove(route: GPXRoute) {
        let index = routes.index(of: route)
        
        if index != NSNotFound {
            route.parent = nil
            routes.remove(route)
        }
    }
    
    public func newTrack() -> GPXTrack {
        let track = GPXTrack()
        
        return track
    }
    
    public func add(track: GPXTrack?) {
        if track != nil {
            let index = tracks.index(of: track!)
            if index == NSNotFound {
                track?.parent = self
                tracks.add(track!)
            }
        }
    }
    
    public func add(tracks: [GPXTrack]) {
        for track in tracks {
            self.add(track: track)
        }
    }
    
    public func remove(track: GPXTrack) {
        let index = tracks.index(of: track)
        
        if index != NSNotFound {
            track.parent = nil
            tracks.remove(track)
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "gpx"
    }
    
    // MARK:- GPX
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        
        let attribute: NSMutableString = ""
        
        if self.schema != nil {
            attribute.appendFormat(" xmlns=\"%@\"", self.schema!)
        }
        
        if self.version != nil {
            attribute.appendFormat(" version=\"%@\"", self.version!)
        }
        
        if self.creator != nil {
            attribute.appendFormat(" creator=\"%@\"", self.creator!)
        }
        
        gpx.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n")
        
        gpx.appendFormat("%@<%@%@>\r\n", self.indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
        
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        if self.metadata != nil {
            self.metadata?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for case let waypoint as GPXWaypoint in self.waypoints {
            waypoint.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for case let route as GPXRoute in self.routes {
            route.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for case let track as GPXTrack in self.tracks {
            track.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if self.extensions != nil {
            self.extensions!.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}

