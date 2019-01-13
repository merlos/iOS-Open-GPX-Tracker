//
//  GPXTrack.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

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
        if link != nil {
            let contains = links.contains(link!)
            if contains == false {
                link?.parent = self
                links.append(link!)
            }
        }
    }
    
    open func add(links: [GPXLink]) {
        for link in links {
            add(link: link)
        }
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
        if trackSegment != nil {
            let contains = tracksegments.contains(trackSegment!)
            if contains == false {
                trackSegment?.parent = self
                tracksegments.append(trackSegment!)
            }
        }
    }
    
    open func add(trackSegments: [GPXTrackSegment]) {
        for tracksegment in trackSegments {
            self.add(trackSegment: tracksegment)
        }
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
    
    open func newTrackPointWith(latitude: CGFloat, longitude: CGFloat) -> GPXTrackPoint {
        var tracksegment: GPXTrackSegment
        
        if tracksegments.count == 0 {
            _ = self.newTrackSegment()
        }
        
        tracksegment = tracksegments.last!
        
        return tracksegment.newTrackpointWith(latitude: latitude, longitude: longitude)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "trk"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name as NSString, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment as NSString, gpx: gpx, tagName: "cmt", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc as NSString, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source as NSString, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        for link in links {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: numberValue as NSString, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type as NSString, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        
        if extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for tracksegment in tracksegments {
            tracksegment.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
