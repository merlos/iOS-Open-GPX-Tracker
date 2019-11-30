//
//  GPXWaypoint.swift
//  GPXKit
//
//  Created by Vincent on 19/11/18.
//

import Foundation

/**
 A value type that represents waypoint based off GPX v1.1 schema's `wptType`.
 
 According to the GPX schema, the waypoint type can represent the following:
    - a waypoint
    - a point of interest
    - a named feature on a map
 
 The waypoint should at least contain the attributes of both `latitude` and `longitude` in order to be considered a valid waypoint. Most attributes are optional, and are not required to be implemented.
*/
public class GPXWaypoint: GPXElement, Codable {
    
    // MARK: Codable Implementation
    
    /// For Codable use
    private enum CodingKeys: String, CodingKey {
        case time
        case elevation = "ele"
        case latitude = "lat"
        case longitude = "lon"
        case magneticVariation = "magvar"
        case geoidHeight = "geoidheight"
        case name
        case comment = "cmt"
        case desc
        case source = "src"
        case symbol = "sym"
        case type
        case fix
        case satellites = "sat"
        case horizontalDilution = "hdop"
        case verticalDilution = "vdop"
        case positionDilution = "pdop"
        case DGPSid = "dgpsid"
        case ageofDGPSData = "ageofdgpsdata"
        case link
        case extensions
    }
    
    
    
    // MARK:- Attributes of a waypoint
    
    /// A value type for link properties (see `GPXLink`)
    ///
    /// Intended for additional information about current point through a web link.
    public var link: GPXLink?
    
    /// Elevation of current point
    ///
    /// Should be in unit **meters** (m)
    public var elevation: Double?
    
    /// Date and time of current point
    ///
    /// Should be in **Coordinated Universal Time (UTC)**, without offsets, not local time.
    public var time: Date?
    
    /// Magnetic Variation of current point
    ///
    /// Should be in unit **degrees** (º)
    public var magneticVariation: Double?
    
    /// Geoid Height of current point
    ///
    /// Should be in unit **meters** (m). Height of geoid, or mean sea level, above WGS84 earth ellipsoid
    public var geoidHeight: Double?
    
    /// Name of current point
    ///
    /// - Warning:
    ///     - This attribute may not be useful, in schema context.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    public var name: String?
    
    /// Comment of current point
    ///
    /// - Warning:
    ///     - This attribute may not be useful, in schema context.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    public var comment: String?
    
    /// Description of current point
    ///
    /// - Warning:
    ///     - This attribute may not be useful, in schema context.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    public var desc: String?
    
    /// Source of data of current point
    ///
    /// For assurance that current point is reliable
    public var source: String?
    
    /// Text of GPS symbol name
    ///
    /// - Warning:
    ///     - This attribute does not appear to be useful due to `CoreLocation` API.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    public var symbol: String?
    
    /// Type of current point
    public var type: String?
    
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
    public var fix: GPXFix?
    
    /// Number of satellites used to calculate GPS fix of current point
    public var satellites: Int?
    
    /// Horizontal dilution of precision of current point
    public var horizontalDilution: Double?
    
    /// Vertical dilution of precision of current point
    public var verticalDilution: Double?
    
    /// Position dilution of precision of current point
    public var positionDilution: Double?
    
    /// Age of DGPS Data
    ///
    /// Number of seconds since last DGPS update
    ///
    /// - Warning:
    ///     - This attribute may not be useful.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    public var ageofDGPSData: Double?
    
    /// DGPS' ID
    ///
    /// ID of DGPS station used in differential correction.
    ///
    /// - Warning:
    ///     - This attribute may not be useful.
    ///     - This is carried over from GPX schema, to be compliant with the schema.
    public var DGPSid: Int?
    
    /// Extension to GPX v1.1 standard.
    public var extensions: GPXExtensions?
    
    /// Latitude of current point
    ///
    /// - Latitude value should be within range of **-90 to 90**
    /// - Should be in unit **degrees** (º)
    /// - Should conform to WGS 84 datum.
    ///
    public var latitude: Double?
    
    /// Longitude of current point
    ///
    /// - Longitude value should be within range of **-180 to 180**
    /// - Should be in unit **degrees** (º)
    /// - Should conform to WGS 84 datum.
    ///
    public var longitude: Double?
    
    
    
    
    // MARK:- Initializers
    
    /// Initialize with current date and time
    ///
    /// The waypoint should be configured appropriately after initializing using this initializer. The `time` attribute will also be set to the time of initializing.
    ///
    /// - Note:
    ///     At least latitude and longitude should be configured as required by the GPX v1.1 schema.
    ///
    public required init() {
        self.time = Date()
        super.init()
    }
    
    /// Initialize with current date and time, with latitude and longitude.
    ///
    /// The waypoint should be configured appropriately after initializing using this initializer. The `time` attribute will also be set to the time of initializing, along with `latitude` and `longitude` attributes.
    ///
    /// - Remark:
    ///     Other attributes can still be configured as per normal.
    ///
    /// - Parameters:
    ///     - latitude: latitude value of the waypoint, in `Double` or `CLLocationDegrees`, **WGS 84** datum only. Should be within the ranges of **-90.0 to 90.0**
    ///     - longitude: longitude value of the waypoint, in `Double` or `CLLocationDegrees`, **WGS 84** datum only. Should be within the ranges of **-180.0 to 180.0**
    ///
    public init(latitude: Double, longitude: Double) {
        self.time = Date()
        super.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Initialize a point type, and verifies that point is within ranges of what latitude and longitude should be.
    ///
    /// - SeeAlso:
    /// init(latitude:longitude:)
    public convenience init(verifiedLatitude latitude: Double, longitude: Double) throws {
        guard let error = GPXError.checkError(latitude: latitude, longitude: longitude) else {
            self.init(latitude: latitude, longitude: longitude)
            return }
        
        throw error
        
    }
    
    /// Inits native element from raw parser value
    ///
    /// - Parameters:
    ///     - raw: Raw element expected from parser
    init(raw: GPXRawElement) {
        self.latitude = Convert.toDouble(from: raw.attributes["lat"])
        self.longitude = Convert.toDouble(from: raw.attributes["lon"])
        
        for child in raw.children {
            switch child.name {
            case "time":        self.time = GPXDateParser.parse(date: child.text)
            case "ele":         self.elevation = Convert.toDouble(from: child.text)
            case "magvar":      self.magneticVariation = Convert.toDouble(from: child.text)
            case "geoidheight": self.geoidHeight = Convert.toDouble(from: child.text)
            case "name":        self.name = child.text
            case "cmt":         self.comment = child.text
            case "desc":        self.desc = child.text
            case "src":         self.source = child.text
            case "sym":         self.symbol = child.text
            case "type":        self.type = child.text
            case "fix":         self.fix = GPXFix(rawValue: child.text ?? "none")
            case "sat":         self.satellites = Convert.toInt(from: child.text)
            case "hdop":        self.horizontalDilution = Convert.toDouble(from: child.text)
            case "vdop":        self.verticalDilution = Convert.toDouble(from: child.text)
            case "pdop":        self.positionDilution = Convert.toDouble(from: child.text)
            case "dgpsid":      self.DGPSid = Convert.toInt(from: child.text)
            case "ageofdgpsid": self.ageofDGPSData = Convert.toDouble(from: child.text)
            case "extensions":  self.extensions = GPXExtensions(raw: child)
            default: continue
            }
        }
    }
    
    // MARK:- Public Methods
    
    /// for initializing a `GPXLink` with href, which is added to this point type as well.
    ///   - Parameters:
    ///        - href: a URL hyperlink as a `String`
    ///
    /// This method works by initializing a new `GPXLink`, adding to this point type, then return the `GPXLink`
    ///
    ///   - Warning: Will be deprecated starting version 0.5.0
    @available(*, deprecated, message: "Initialize GPXLink first then, add it to this point type instead.")
    public func newLink(withHref href: String) -> GPXLink {
        let link = GPXLink(withHref: href)
        self.link = link
        return link
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "wpt"
    }
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        if let latitude = latitude {
            attribute.append(" lat=\"\(latitude)\"")
        }
        
        if let longitude = longitude {
            attribute.append(" lon=\"\(longitude)\"")
        }
        
        gpx.appendOpenTag(indentation: indent(forIndentationLevel: indentationLevel), tag: tagName(), attribute: attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forDoubleValue: elevation, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: Convert.toString(from: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: magneticVariation, gpx: gpx, tagName: "magvar", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: geoidHeight, gpx: gpx, tagName: "geoidheight", indentationLevel: indentationLevel)
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment, gpx: gpx, tagName: "cmt", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source, gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        
        if self.link != nil {
            self.link?.gpx(gpx, indentationLevel: indentationLevel)
        }
 
        self.addProperty(forValue: symbol, gpx: gpx, tagName: "sym", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        
        if let fix = self.fix?.rawValue {
            self.addProperty(forValue: fix, gpx: gpx, tagName: "fix", indentationLevel: indentationLevel)
        }
        
        self.addProperty(forIntegerValue: satellites, gpx: gpx, tagName: "sat", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: horizontalDilution, gpx: gpx, tagName: "hdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: verticalDilution, gpx: gpx, tagName: "vdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: positionDilution, gpx: gpx, tagName: "pdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: ageofDGPSData, gpx: gpx, tagName: "ageofdgpsdata", indentationLevel: indentationLevel)
        self.addProperty(forIntegerValue: DGPSid, gpx: gpx, tagName: "dgpsid", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
