//
//  CLActivityType+Info.swift
//  OpenGpxTracker
//
//  Created by Vincent on 22/7/19.
//

import CoreLocation

extension CLActivityType {
    
    var name: String {
        switch self {
        case .other:                return "Other"
        case .automotiveNavigation: return "Automotive Navigation"
        case .fitness:              return "Fitness"
        case .otherNavigation:      return "Other Navigation"
        case .airborne:             return "Airborne"
        @unknown default:
            return "Unknown Type: \(self.rawValue)"
        }
    }
    
    var count: Int {
        return 5
    }
    
}
