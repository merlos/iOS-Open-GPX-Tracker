//
//  GPXTrack.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

open class GPXTrack: GPXElement {
    
    public var links = NSMutableArray()
    public var tracksegments = NSMutableArray()
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
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
        
        name = text(forSingleChildElement: "name", xmlElement: element)
        comment = text(forSingleChildElement: "cmt", xmlElement: element)
        desc = text(forSingleChildElement: "desc", xmlElement: element)
        source = text(forSingleChildElement: "src", xmlElement: element)
        
        self.childElement(ofClass: GPXLink.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.links.add(element!)
            } })
        
        numberValue = text(forSingleChildElement: "number", xmlElement: element)
        type = text(forSingleChildElement: "type", xmlElement: element)
        extensions = childElement(ofClass: GPXExtensions.self, xmlElement: element) as? GPXExtensions
        
        self.childElement(ofClass: GPXTrackSegment.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.tracksegments.add(element!)
            } })
        
        self.number = GPXType().nonNegativeInt(numberValue)
    }
    
    // MARK:- Public Methods
    
    /*
    var number: Int {
        return GPXType().nonNegativeInt(numberValue)
    }
    */
    
    open func set(number: Int) {
        numberValue = GPXType().value(forNonNegativeInt: number)
    }
    
    open func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
    open func add(link: GPXLink?) {
        if link != nil {
            let index = links.index(of: link!)
            if index == NSNotFound {
                link?.parent = self
                links.add(link!)
            }
        }
    }
    
    open func add(links: [GPXLink]) {
        for link in links {
            add(link: link)
        }
    }
    
    open func remove(Link link: GPXLink) {
        let index = links.index(of: link)
        
        if index != NSNotFound {
            link.parent = nil
            links.remove(link)
        }
    }
    
    open func newTrackSegment() -> GPXTrackSegment {
        let tracksegment = GPXTrackSegment()
        self.add(trackSegment: tracksegment)
        return tracksegment
    }
    
    open func add(trackSegment: GPXTrackSegment?) {
        if trackSegment != nil {
            let index = tracksegments.index(of: trackSegment!)
            if index == NSNotFound {
                trackSegment?.parent = self
                tracksegments.add(trackSegment!)
            }
        }
    }
    
    open func add(trackSegments: [GPXTrackSegment]) {
        for tracksegment in trackSegments {
            self.add(trackSegment: tracksegment)
        }
    }
    
    open func remove(trackSegment: GPXTrackSegment) {
        let index = tracksegments.index(of: trackSegment)
        if index != NSNotFound {
            trackSegment.parent = nil
            tracksegments.remove(trackSegment)
        }
    }
    
    open func newTrackPointWith(latitude: CGFloat, longitude: CGFloat) -> GPXTrackPoint {
        var tracksegment: GPXTrackSegment
        
        if tracksegments.count == 0 {
            _ = self.newTrackSegment()
        }
        
        tracksegment = tracksegments.lastObject as! GPXTrackSegment
        
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
        
        for case let link as GPXLink in self.links {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: numberValue as NSString, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type as NSString, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        
        if extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for case let tracksegent as GPXTrackSegment in self.tracksegments {
            tracksegent.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
