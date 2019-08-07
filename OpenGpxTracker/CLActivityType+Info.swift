//
//  CLActivityType+Info.swift
//  OpenGpxTracker
//
//  Created by Vincent on 22/7/19.
//

import CoreLocation

/// Extends each CLActivityType to have a description and a name.
extension CLActivityType {
    
    /// Returns the string name of this activty type
    var name: String {
        switch self {
        case .other:                return "Automatic"
        case .automotiveNavigation: return "Automotive navigation"
        case .fitness:              return "Fitness"
        case .otherNavigation:      return "Other navigation"
        case .airborne:             return "Flight"
        @unknown default:
            return "Unknown Type: \(self.rawValue)"
        }
    }
    
    /// Returns a brief description of the purpose of the activty.
    /// For example: for the activity type .other the description is
    /// "System default. Automatically selects the mode"
    var description: String {
        switch self {
        case .other:                return "System default. Automatically selects the mode"
        case .automotiveNavigation: return "Car, motorbike, trucks..."
        case .fitness:              return "Running, hiking, cycling..."
        case .otherNavigation:      return "Other than automotive navigation"
        case .airborne:             return "Airborne activities"
        @unknown default:
            return "Unknown Type: \(self.rawValue)"
        }
    }
    
    /// Number of activity types (5)
    static var count: Int {
        return 5
    }
    
}
