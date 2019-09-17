//
//  GPXFix.swift
//  CoreGPX
//
//  Created by Vincent on 2/9/19.
//

import Foundation

/// Type of GPS fix.
///
/// - Note:
///     I believe this enum may not be useful as `CoreLocation` API does not appear to state GPS Fix type.
public enum GPXFix: String, Codable {

    /// No Fix
    case none = "none"
    
    /// 2D Fix, position only.
    case TwoDimensional = "2d"
    
    /// 3D Fix, position and elevation.
    case ThreeDimensional = "3d"
    
    /// Differencial GPS fix
    case Dgps = "dgps"
    
    /// Military GPS-equivalent
    case Pps = "pps"
    
}
