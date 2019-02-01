//
//  GPXPointSegment.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//

import UIKit

open class GPXPointSegment: GPXElement {
    
    var points = [GPXPoint]()
    
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
        if point != nil {
            let contains = points.contains(point!)
            if contains == false {
                point?.parent = self
                points.append(point!)
            }
        }
    }
    
    public func add(points: [GPXPoint]) {
        for point in points {
            add(point: point)
        }
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
    
    override func tagName() -> String! {
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
