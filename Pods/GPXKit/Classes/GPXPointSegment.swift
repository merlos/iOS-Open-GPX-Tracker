//
//  GPXPointSegment.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//

import UIKit

open class GPXPointSegment: GPXElement {
    
    var points = NSMutableArray()
    
    // MARK:- Instance
    
    override init() {
        super.init()
    }
    
    override init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
        
        self.childElement(ofClass: GPXPoint.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.points.add(element!)
            } })
    }
    
    // MARK:- Public Methods
    
    func newPoint(with latitude: CGFloat, longitude: CGFloat) -> GPXPoint {
        let point: GPXPoint = GPXPoint().point(with: latitude, longitude: longitude)
        
        self.add(point: point)
        
        return point
    }
    
    func add(point: GPXPoint?) {
        if point != nil {
            let index = points.index(of: point!)
            if index == NSNotFound {
                point?.parent = self
                points.add(point!)
            }
        }
    }
    
    func add(points array: NSArray) {
        for case let point as GPXPoint in array {
            add(point: point)
        }
    }
    
    func remove(point: GPXPoint?) {
        let index = points.index(of: point!)
        if index != NSNotFound {
            point?.parent = nil
            points.remove(point!)
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "ptseg"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        for case let point as GPXPoint in self.points {
            point.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
