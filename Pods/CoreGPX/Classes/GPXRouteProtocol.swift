//
//  GPXRouteProtocol.swift
//  Pods
//
//  Created by Vincent Neo on 13/6/20.
//

import Foundation

public protocol GPXRouteType {
    /// Name of the route.
    var name: String? { get set }
    
    /// Additional comment of the route.
    var comment: String? { get set }
    
    /// Description of the route.
    var desc: String? { get set }
    
    /// Source of the route.
    var source: String? { get set }
    
    /// Number of route (possibly a tag for the route)
    var number: Int? { get set }
}
