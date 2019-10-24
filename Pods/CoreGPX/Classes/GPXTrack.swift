//
//  GPXTrack.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import Foundation

/**
 Represents `trkType` of GPX v1.1 schema.
 
 A track can hold track segments, along with additional information regarding the track.
 
 Tracks are meant to show the start and finish of a journey, through the track segments that it holds.
 */
public final class GPXTrack: GPXElement, Codable {
    
    /// for Codable
    private enum CodingKeys: String, CodingKey {
        case link
        case tracksegments = "trkseg"
        case name
        case comment = "cmt"
        case desc
        case source = "src"
        case number
        case type
        case extensions
    }
    
    /// Holds a web link to external resources regarding the current track.
    public var link: GPXLink?
    
    /// Array of track segements. Must be included in every track.
    public var tracksegments = [GPXTrackSegment]()
    
    /// Name of track.
    public var name: String?
    
    /// Additional comment of track.
    public var comment: String?
    
    /// A full description of the track. Can be of any length.
    public var desc: String?
    
    /// Source of track.
    public var source: String?
    
    /// GPS track number.
    public var number: Int?
    
    /// Type of current track.
    public var type: String?
    
    /// Custom Extensions of track, if needed.
    public var extensions: GPXExtensions?

    /// Default Initializer
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
            case "link":        self.link = GPXLink(raw: child)
            case "trkseg":      self.tracksegments.append(GPXTrackSegment(raw: child))
            case "name":        self.name = child.text
            case "cmt":         self.comment = child.text
            case "desc":        self.desc = child.text
            case "src":         self.source = child.text
            case "type":        self.type = child.text
            case "extensions":  self.extensions = GPXExtensions(raw: child)
            default: continue
            }
        }
    }
    
    // MARK:- Public Methods
    
    /// Initialize a new `GPXLink` to the track.
    ///
    /// Method not recommended for use. Please initialize `GPXLink` manually and adding it to the track instead.
    public func newLink(withHref href: String) -> GPXLink {
        let link = GPXLink(withHref: href)
        return link
    }

    /// Initialize a new `GPXTrackSegement` to the track.
    ///
    /// Method not recommended for use. Please initialize `GPXTrackSegment` manually and adding it to the track instead.
    public func newTrackSegment() -> GPXTrackSegment {
        let tracksegment = GPXTrackSegment()
        self.add(trackSegment: tracksegment)
        return tracksegment
    }
    
    /// Adds a single track segment to the track.
    public func add(trackSegment: GPXTrackSegment?) {
        if let validTrackSegment = trackSegment {
            tracksegments.append(validTrackSegment)
        }
    }
    
    /// Adds an array of track segments to the track.
    public func add(trackSegments: [GPXTrackSegment]) {
        self.tracksegments.append(contentsOf: trackSegments)
    }
    
    /// Removes a tracksegment from the track.
    public func remove(trackSegment: GPXTrackSegment) {
        let contains = tracksegments.contains(trackSegment)
        
        if contains == true {
            if let index = tracksegments.firstIndex(of: trackSegment) {
                tracksegments.remove(at: index)
            }
        }
    }
    
    /// Initializes a new track point in track, then returns the new track point.
    public func newTrackPointWith(latitude: Double, longitude: Double) -> GPXTrackPoint {
        var tracksegment: GPXTrackSegment
        
        if let lastTracksegment = tracksegments.last {
            tracksegment = lastTracksegment
        } else {
            tracksegment = self.newTrackSegment()
        }
        
        return tracksegment.newTrackpointWith(latitude: latitude, longitude: longitude)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "trk"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment, gpx: gpx, tagName: "cmt", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        if let link = link {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forIntegerValue: number, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        
        if extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for tracksegment in tracksegments {
            tracksegment.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
