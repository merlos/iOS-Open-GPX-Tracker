//
//  GPXTrack.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

open class GPXTrack: GPXElement {
    var links = NSMutableArray()
    var tracksegments = NSMutableArray()
    var numberValue = String()
    var name = String()
    var comment = String()
    var desc = String()
    var source = String()
    //var number = Int()
    var type = String()
    var extensions: GPXExtensions?

    
    override init() {
        super.init()
    }
    
    override init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
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
    }
    
    // MARK:- Public Methods
    
    var number: Int {
        return GPXType().nonNegativeInt(numberValue)
    }
    
    func set(number: Int) {
        numberValue = GPXType().value(forNonNegativeInt: number)
    }
    
    func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
    func add(Link link: GPXLink?) {
        if link != nil {
            let index = links.index(of: link!)
            if index == NSNotFound {
                link?.parent = self
                links.add(link!)
            }
        }
    }
    
    func add(Links array: NSArray) {
        for case let link as GPXLink in array {
            add(Link: link)
        }
    }
    
    func remove(Link link: GPXLink) {
        let index = links.index(of: link)
        
        if index != NSNotFound {
            link.parent = nil
            links.remove(link)
        }
    }
    
    func newTrackSegment() -> GPXTrackSegment {
        let tracksegment = GPXTrackSegment()
        self.add(trackSegment: tracksegment)
        return tracksegment
    }
    
    func add(trackSegment: GPXTrackSegment?) {
        if trackSegment != nil {
            let index = tracksegments.index(of: trackSegment!)
            if index == NSNotFound {
                trackSegment?.parent = self
                tracksegments.add(trackSegment!)
            }
        }
    }
    
    func add(trackSegments: NSArray) {
        for case let tracksegment as GPXTrackSegment in trackSegments {
            self.add(trackSegment: tracksegment)
        }
    }
    
    func remove(trackSegment: GPXTrackSegment) {
        let index = tracksegments.index(of: trackSegment)
        if index != NSNotFound {
            trackSegment.parent = nil
            tracksegments.remove(trackSegment)
        }
    }
    
    func newTrackPointWith(latitude: CGFloat, longitude: CGFloat) -> GPXTrackPoint {
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
            self.extensions!.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for case let tracksegent as GPXTrackSegment in self.tracksegments {
            tracksegent.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
