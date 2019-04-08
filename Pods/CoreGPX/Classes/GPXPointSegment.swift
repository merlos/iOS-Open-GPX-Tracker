//
//  GPXPointSegment.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//

import Foundation

/**
 * This class (`ptsegType`) is added to conform with the GPX v1.1 schema.
 
 `ptsegType` of GPX schema. Not supported in GPXRoot, nor GPXParser's parsing.
 */
open class GPXPointSegment: GPXElement {
    
    public var points = [GPXPoint]()
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    // MARK:- Public Methods
    
    public func newPoint(with latitude: Double, longitude: Double) -> GPXPoint {

        let point = GPXPoint(latitude: latitude, longitude: longitude)
        
        self.add(point: point)
        
        return point
    }
    
    public func add(point: GPXPoint?) {
        if let validPoint = point {
            point?.parent = self
            points.append(validPoint)
        }
    }
    
    public func add(points: [GPXPoint]) {
        self.points.append(contentsOf: points)
    }
    
    public func remove(point: GPXPoint) {
        let contains = points.contains(point)
        if contains == true {
            point.parent = nil
            if let index = points.firstIndex(of: point) {
                points.remove(at: index)
            }
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "ptseg"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        for point in points {
            point.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
