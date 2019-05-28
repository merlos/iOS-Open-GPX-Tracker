//
//  GPXTrackSegment.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import Foundation

/**
 A track segment that holds data on all track points in the particular segment.

 Does not hold additional information by default.
 */
open class GPXTrackSegment: GPXElement, Codable {
    
    /// For Codable use
    enum CodingKeys: String, CodingKey {
        case trackpoints = "trkpt"
        case extensions
    }
    
    public var trackpoints = [GPXTrackPoint]()
    public var extensions: GPXExtensions?
    
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    // MARK:- Public Methods
    
    open func newTrackpointWith(latitude: Double, longitude: Double) -> GPXTrackPoint {
        let trackpoint = GPXTrackPoint(latitude: latitude, longitude: longitude)
        
        self.add(trackpoint: trackpoint)
        
        return trackpoint
    }
    
    /// Adds a single track point to this track segment.
    open func add(trackpoint: GPXTrackPoint?) {
        if let validPoint = trackpoint {
            trackpoints.append(validPoint)
        }
    }
    
    /// Adds an array of track points to this track segment.
    open func add(trackpoints: [GPXTrackPoint]) {
        self.trackpoints.append(contentsOf: trackpoints)
    }
    
    /// Removes a track point from this track segment.
    open func remove(trackpoint: GPXTrackPoint) {
        trackpoint.parent = nil
        if let index = trackpoints.firstIndex(of: trackpoint) {
            trackpoints.remove(at: index)
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
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
