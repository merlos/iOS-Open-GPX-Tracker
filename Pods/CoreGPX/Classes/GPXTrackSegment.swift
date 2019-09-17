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
public final class GPXTrackSegment: GPXElement, Codable {
    
    /// For Codable use
    private enum CodingKeys: String, CodingKey {
        case trackpoints = "trkpt"
        case extensions
    }
    
    
    /// Track points stored in current segment.
    public var trackpoints = [GPXTrackPoint]()
    
    /// Custom Extensions, if needed.
    public var extensions: GPXExtensions?
    
    
    // MARK:- Instance
    
    /// Default Initializer.
    public required init() {
        super.init()
    }
    
    /// Inits native element from raw parser value
    ///
    /// - Parameters:
    ///     - raw: Raw element expected from parser
    init(raw: GPXRawElement) {
        for child in raw.children {
            switch child.name {
            case "trkpt":       self.trackpoints.append(GPXTrackPoint(raw: child))
            case "extensions":  self.extensions = GPXExtensions(raw: child)
            default: continue
            }
        }
    }
    
    // MARK:- Public Methods
    
    /// Initializes a new trackpoint to segment, and returns the trackpoint.
    public func newTrackpointWith(latitude: Double, longitude: Double) -> GPXTrackPoint {
        let trackpoint = GPXTrackPoint(latitude: latitude, longitude: longitude)
        
        self.add(trackpoint: trackpoint)
        
        return trackpoint
    }
    
    /// Adds a single track point to this track segment.
    public func add(trackpoint: GPXTrackPoint?) {
        if let validPoint = trackpoint {
            trackpoints.append(validPoint)
        }
    }
    
    /// Adds an array of track points to this track segment.
    public func add(trackpoints: [GPXTrackPoint]) {
        self.trackpoints.append(contentsOf: trackpoints)
    }
    
    /// Removes a track point from this track segment.
    public func remove(trackpoint: GPXTrackPoint) {
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
