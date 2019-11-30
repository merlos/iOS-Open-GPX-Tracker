//
//  GPXBounds.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import Foundation

/**
 A value type that represents bounds based off GPX v1.1 schema's `boundsType`.
 
 This is meant for having two pairs of longitude and latitude, signifying the maximum and minimum, defining the extent / boundaries of a particular element.
 */
public final class GPXBounds: GPXElement, Codable {
    
    /// Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case minLatitude = "minlat"
        case maxLatitude = "maxLat"
        case minLongitude = "minlon"
        case maxLongitude = "maxlon"
    }
    
    /// Minimum latitude of boundaries to a element.
    public var minLatitude: Double?
    /// Maximum latitude of boundaries to a element.
    public var maxLatitude: Double?
    /// Minimum longitude of boundaries to a element.
    public var minLongitude: Double?
    /// Maximum longitude of boundaries to a element.
    public var maxLongitude: Double?
    
    // MARK:- Initalizers
    
    /// Default initializer.
    public required init() {
        super.init()
    }
    
    /// Initializes with all values
    ///
    /// - Parameters:
    ///     - minLatitude: Minimum latitude
    ///     - maxLatitude: Maximum latitude
    ///     - minLongitude: Minimum longitude
    ///     - maxLongitude: Maximum longitude
    public init(minLatitude: Double, maxLatitude: Double, minLongitude: Double, maxLongitude: Double) {
        super.init()
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    /// Inits native element from raw parser value
    ///
    /// - Parameters:
    ///     - raw: Raw element expected from parser
    init(raw: GPXRawElement) {
        self.minLatitude = Convert.toDouble(from: raw.attributes["minlat"])
        self.maxLatitude = Convert.toDouble(from: raw.attributes["maxlat"])
        self.minLongitude = Convert.toDouble(from: raw.attributes["minlon"])
        self.maxLongitude = Convert.toDouble(from: raw.attributes["maxlon"])
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "bounds"
    }
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        if let minLatitude = minLatitude {
            attribute.append(" minlat=\"\(minLatitude)\"")
        }
        if let minLongitude = minLongitude {
            attribute.append(" minlon=\"\(minLongitude)\"")
        }
        if let maxLatitude = maxLatitude {
            attribute.append(" maxlat=\"\(maxLatitude)\"")
        }
        if let maxLongitude = maxLongitude {
            attribute.append(" maxlon=\"\(maxLongitude)\"")
        }
        gpx.appendOpenTag(indentation: indent(forIndentationLevel: indentationLevel), tag: tagName(), attribute: attribute)
    }
}
