//
//  GPXWaypointProtocol.swift
//  Pods
//
//  Created by Vincent Neo on 13/6/20.
//

import Foundation

public protocol GPXWaypointProtocol: GPXElement {
    // MARK:- Attributes of a waypoint
    
    /// Elevation of current point
    ///
    /// Should be in unit **meters** (m)
    var elevation: Double? { get set }
    
    /// Date and time of current point
    ///
    /// Should be in **Coordinated Universal Time (UTC)**, without offsets, not local time.
    var time: Date? { get set }
    
    /// Magnetic Variation of current point
    ///
    /// Should be in unit **degrees** (º)
    var magneticVariation: Double? { get set }
    
    /// Geoid Height of current point
    ///
    /// Should be in unit **meters** (m). Height of geoid, or mean sea level, above WGS84 earth ellipsoid
    var geoidHeight: Double? { get set }
    
    /// Name of current point
    ///
    /// - Warning:
    ///     - This attribute may not be useful, in schema context.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    var name: String? { get set }
    
    /// Comment of current point
    ///
    /// - Warning:
    ///     - This attribute may not be useful, in schema context.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    var comment: String? { get set }
    
    /// Description of current point
    ///
    /// - Warning:
    ///     - This attribute may not be useful, in schema context.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    var desc: String? { get set }
    
    /// Source of data of current point
    ///
    /// For assurance that current point is reliable
    var source: String? { get set }
    
    /// Text of GPS symbol name
    ///
    /// - Warning:
    ///     - This attribute does not appear to be useful due to `CoreLocation` API.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    var symbol: String? { get set }
    
    /// Type of current point
    var type: String? { get set }
    
    /// Type of GPS fix of current point, represented as a number
    ///
    /// - **Supported Types:** (written in order)
    ///     - **None**: No fix
    ///     - **2D**: Position only
    ///     - **3D**: Position and Elevation
    ///     - **DGPS**: Differential GPS
    ///     - **PPS**: Military Signal
    ///
    /// Unknown fix should leave fix attribute as `nil`
    /// - Warning:
    ///     - This attribute may have limited usefulness due to `CoreLocation` API.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    var fix: GPXFix? { get set }
    
    /// Number of satellites used to calculate GPS fix of current point
    var satellites: Int? { get set }
    
    /// Horizontal dilution of precision of current point
    var horizontalDilution: Double? { get set }
    
    /// Vertical dilution of precision of current point
    var verticalDilution: Double? { get set }
    
    /// Position dilution of precision of current point
    var positionDilution: Double? { get set }
    
    /// Age of DGPS Data
    ///
    /// Number of seconds since last DGPS update
    ///
    /// - Warning:
    ///     - This attribute may not be useful.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    var ageofDGPSData: Double? { get set }
    
    /// DGPS' ID
    ///
    /// ID of DGPS station used in differential correction.
    ///
    /// - Warning:
    ///     - This attribute may not be useful.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    var DGPSid: Int? { get set }
    
    
    /// Latitude of current point
    ///
    /// - Latitude value should be within range of **-90 to 90**
    /// - Should be in unit **degrees** (º)
    /// - Should conform to WGS 84 datum.
    ///
    var latitude: Double? { get set }
    
    /// Longitude of current point
    ///
    /// - Longitude value should be within range of **-180 to 180**
    /// - Should be in unit **degrees** (º)
    /// - Should conform to WGS 84 datum.
    ///
    var longitude: Double? { get set }
    
}

extension GPXWaypointProtocol {
    func convert<T: GPXWaypointProtocol>() -> T {
        let wpt = T()
        wpt.elevation = elevation
        wpt.time = time
        wpt.magneticVariation = magneticVariation
        wpt.geoidHeight = geoidHeight
        wpt.name = name
        wpt.comment = comment
        wpt.desc = desc
        wpt.source = source
        wpt.symbol = symbol
        wpt.type = type
        wpt.fix = fix
        wpt.satellites = satellites
        wpt.horizontalDilution = horizontalDilution
        wpt.verticalDilution = verticalDilution
        wpt.positionDilution = positionDilution
        wpt.ageofDGPSData = ageofDGPSData
        wpt.DGPSid = DGPSid
        wpt.latitude = latitude
        wpt.longitude = longitude
        return wpt
    }
}
