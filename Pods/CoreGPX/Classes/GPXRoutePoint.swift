//
//  GPXRoutePoint.swift
//  GPXKit
//
//  Created by Vincent on 19/11/18.
//

import Foundation

/**
 A route point is just like a waypoint or track point, but is suited to be part of a route.
 
 These route points in collective, forms a valid route.
 */
public final class GPXRoutePoint: GPXWaypoint {
    
    /// Default initializer
    public required init() {
        super.init()
    }
    
    // MARK:- Instance
    
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
        return "rtept"
    }
}
