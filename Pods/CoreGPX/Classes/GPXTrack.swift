//
//  GPXTrack.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import Foundation

open class GPXTrack: GPXElement {
    
    public var links = [GPXLink]()
    public var tracksegments = [GPXTrackSegment]()
    public var numberValue = String()
    public var name = String()
    public var comment = String()
    public var desc = String()
    public var source = String()
    public var number = Int()
    public var type = String()
    public var extensions: GPXExtensions?

    
    public required init() {
        super.init()
    }
    
    // MARK:- Public Methods
    
    open func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
    open func add(link: GPXLink?) {
        if let validLink = link {
            validLink.parent = self
            links.append(validLink)
        }
    }
    
    open func add(links: [GPXLink]) {
        self.links.append(contentsOf: links)
    }
    
    open func remove(Link link: GPXLink) {
        let contains = links.contains(link)
        
        if contains == true {
            link.parent = nil
            if let index = links.firstIndex(of: link) {
                links.remove(at: index)
            }
        }
    }
    
    open func newTrackSegment() -> GPXTrackSegment {
        let tracksegment = GPXTrackSegment()
        self.add(trackSegment: tracksegment)
        return tracksegment
    }
    
    open func add(trackSegment: GPXTrackSegment?) {
        if let validTrackSegment = trackSegment {
            validTrackSegment.parent = self
            tracksegments.append(validTrackSegment)
        }
    }
    
    open func add(trackSegments: [GPXTrackSegment]) {
        self.tracksegments.append(contentsOf: trackSegments)
    }
    
    open func remove(trackSegment: GPXTrackSegment) {
        let contains = tracksegments.contains(trackSegment)
        
        if contains == true {
            trackSegment.parent = nil
            if let index = tracksegments.firstIndex(of: trackSegment) {
                tracksegments.remove(at: index)
            }
        }
    }
    
    open func newTrackPointWith(latitude: Double, longitude: Double) -> GPXTrackPoint {
        var tracksegment: GPXTrackSegment
        
        if let lastTracksegment = tracksegments.last {
            tracksegment = lastTracksegment
        } else {
            tracksegment = self.newTrackSegment()
        }
        
        return tracksegment.newTrackpointWith(latitude: latitude, longitude: longitude)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "trk"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment, gpx: gpx, tagName: "cmt", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        for link in links {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: numberValue, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        
        if extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for tracksegment in tracksegments {
            tracksegment.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
