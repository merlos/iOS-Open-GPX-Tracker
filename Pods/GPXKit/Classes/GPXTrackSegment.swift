//
//  GPXTrackSegment.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

open class GPXTrackSegment: GPXElement {
    
    public var trackpoints = [GPXTrackPoint]()
    public var extensions: GPXExtensions?
    
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
        
        extensions = childElement(ofClass: GPXExtensions.self, xmlElement: element) as? GPXExtensions
        
        self.childElement(ofClass: GPXTrackPoint.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.trackpoints.append(element! as! GPXTrackPoint)
            } })
    }
    
    // MARK:- Public Methods
    
    open func newTrackpointWith(latitude: CGFloat, longitude: CGFloat) -> GPXTrackPoint {
        let trackpoint = GPXTrackPoint().trackpointWith(latitude: latitude, longitude: longitude)
        self.add(trackpoint: trackpoint)
        
        return trackpoint
    }
    
    open func add(trackpoint: GPXTrackPoint?) {
        if trackpoint != nil {
            let contains = trackpoints.contains(trackpoint!)
            if contains == false {
                trackpoint?.parent = self
                trackpoints.append(trackpoint!)
            }
        }
    }
    
    open func add(trackpoints: [GPXTrackPoint]) {
        for trackpoint in trackpoints {
            self.add(trackpoint: trackpoint)
        }
    }
    
    open func remove(trackpoint: GPXTrackPoint) {
        let contains = trackpoints.contains(trackpoint)
        if contains == true {
            trackpoint.parent = nil
            if let index = trackpoints.firstIndex(of: trackpoint) {
                trackpoints.remove(at: index)
            }
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "trkseg"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for trackpoint in trackpoints {
            trackpoint.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
