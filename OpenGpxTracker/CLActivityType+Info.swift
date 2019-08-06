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
        case .other:                return "Automatic"
        case .automotiveNavigation: return "Automotive navigation"
        case .fitness:              return "Fitness"
        case .otherNavigation:      return "Other navigation"
        case .airborne:             return "Flight"
        @unknown default:
            return "Unknown Type: \(self.rawValue)"
        }
    }
    
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
    
    
    
    var count: Int {
        return 5
    }
    
}
