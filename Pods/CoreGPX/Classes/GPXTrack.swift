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
open class GPXTrack: GPXElement, Codable {
    
    /// for Codable
    enum CodingKeys: String, CodingKey {
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
    
    /// Internal Initializer, for parsing use only.
    init(dictionary: inout [String : String]) {
        super.init()
        dictionary.removeValue(forKey: self.tagName())
        self.number = Convert.toInt(from: dictionary.removeValue(forKey: "number"))
        self.name = dictionary.removeValue(forKey: "name")
        self.comment = dictionary.removeValue(forKey: "cmt")
        self.desc = dictionary.removeValue(forKey: "desc")
        self.source = dictionary.removeValue(forKey: "src")
        self.type = dictionary.removeValue(forKey: "type")
        
        if dictionary.count > 0 {
            self.extensions = GPXExtensions(dictionary: dictionary)
        }
    }
    
    // MARK:- Public Methods
    
    /// Initialize a new `GPXLink` to the track.
    ///
    /// Method not recommended for use. Please initialize `GPXLink` manually and adding it to the track instead.
    open func newLink(withHref href: String) -> GPXLink {
        let link = GPXLink(withHref: href)
        return link
    }

    /// Initialize a new `GPXTrackSegement` to the track.
    ///
    /// Method not recommended for use. Please initialize `GPXTrackSegment` manually and adding it to the track instead.
    open func newTrackSegment() -> GPXTrackSegment {
        let tracksegment = GPXTrackSegment()
        self.add(trackSegment: tracksegment)
        return tracksegment
    }
    
    /// Adds a single track segment to the track.
    open func add(trackSegment: GPXTrackSegment?) {
        if let validTrackSegment = trackSegment {
            validTrackSegment.parent = self
            tracksegments.append(validTrackSegment)
        }
    }
    
    /// Adds an array of track segments to the track.
    open func add(trackSegments: [GPXTrackSegment]) {
        self.tracksegments.append(contentsOf: trackSegments)
    }
    
    /// Removes a tracksegment from the track.
    open func remove(trackSegment: GPXTrackSegment) {
        let contains = tracksegments.contains(trackSegment)
        
        if contains == true {
            trackSegment.parent = nil
            if let index = tracksegments.firstIndex(of: trackSegment) {
                tracksegments.remove(at: index)
            }
        }
    }
    
    /// Initializes a new track point in track, then returns the new track point.
    open func newTrackPointWith(latitude: Double, longitude: Double) -> GPXTrackPoint {
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
