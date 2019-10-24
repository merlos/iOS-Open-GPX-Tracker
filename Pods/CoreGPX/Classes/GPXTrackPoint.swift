//
//  GPXTrackPoint.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import Foundation

/**
 A track point is just like a waypoint or route point, but is suited to be part of a track segment.
 
 A bunch of track points can be used to form a track segement, while track segments form a track.
 (though a single track segment itself is enough to form a track.)
 */
public final class GPXTrackPoint: GPXWaypoint {
    
    // MARK:- Initializers
    
    /// Default Initializer.
    public required init() {
        super.init()
    }
    
    public override init(latitude: Double, longitude: Double) {
        super.init(latitude: latitude, longitude: longitude)
    }
    
    override init(raw: GPXRawElement) {
        super.init(raw: raw)
    }
    
    /// For initializing with a `Decoder`
    ///
    /// Declared here for use of Codable functionalities.
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }

    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "trkpt"
    }
    
}
