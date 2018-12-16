//
//  GPXTrackSegment.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

open class GPXTrackSegment: GPXElement {
    
    public let trackpoints = NSMutableArray()
    var extensions: GPXExtensions?
    
    
    // MARK:- Instance
    
    override init() {
        super.init()
    }
    
    override init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
        
        extensions = childElement(ofClass: GPXExtensions.self, xmlElement: element) as! GPXExtensions?
        
        self.childElement(ofClass: GPXTrackPoint.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.trackpoints.add(element!)
            } })
    }
    
    // MARK:- Public Methods
    
    func newTrackpointWith(latitude: CGFloat, longitude: CGFloat) -> GPXTrackPoint {
        let trackpoint = GPXTrackPoint().trackpointWith(latitude: latitude, longitude: longitude)
        self.add(trackpoint: trackpoint)
        
        return trackpoint
    }
    
    func add(trackpoint: GPXTrackPoint?) {
        if trackpoint != nil {
            let index = trackpoints.index(of: trackpoint!)
            
            if index == NSNotFound {
                trackpoint?.parent = self
                trackpoints.add(trackpoint!)
            }
        }
    }
    
    func add(trackpoints: NSArray) {
        for case let trackpoint as GPXTrackPoint in trackpoints {
            self.add(trackpoint: trackpoint)
        }
    }
    
    func remove(trackpoint: GPXTrackPoint) {
        let index = trackpoints.index(of: trackpoint)
        
        if index != NSNotFound {
            trackpoint.parent = nil
            trackpoints.remove(trackpoint)
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
            self.extensions!.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for case let trackpoint as GPXTrackPoint in self.trackpoints {
            trackpoint.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
