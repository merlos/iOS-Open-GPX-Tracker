//
//  GPXRoutePoint.swift
//  GPXKit
//
//  Created by Vincent on 19/11/18.
//

import Foundation

open class GPXRoutePoint: GPXWaypoint {
    
    /// Default initializer
    public required init() {
        super.init()
    }
    
    // MARK:- Instance
    
    public override init(latitude: Double, longitude: Double) {
        super.init(latitude: latitude, longitude: longitude)
    }
    
    override init(dictionary: inout [String : String]) {
        super.init(dictionary: &dictionary)
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
