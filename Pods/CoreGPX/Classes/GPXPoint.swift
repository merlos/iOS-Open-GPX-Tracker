//
//  GPXPoint.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//

import Foundation

/**
 * This class (`ptType`) is added to conform with the GPX v1.1 schema.
 
 `ptType` of GPX schema. Not supported in GPXRoot, nor GPXParser's parsing.
 */
open class GPXPoint: GPXElement, Codable {

    /// Elevation Value in (metre, m)
    public var elevation: Double?
    /// Time/Date of creation
    public var time: Date?
    /// Latitude of point
    public var latitude: Double?
    /// Longitude of point
    public var longitude: Double?
    
    // MARK:- Instance
    
    /// Default Initializer.
    required public init() {
        super.init()
    }
    /// Initialize with latitude and longitude
    public init(latitude: Double, longitude: Double) {
        super.init()
        self.latitude = latitude
        self.longitude = longitude
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
            case "ele": self.elevation = Convert.toDouble(from: child.text)
            case "time": self.time = GPXDateParser.parse(date: child.text)
            default: continue
            }
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "pt"
    }
    
    // MARK: GPX
    
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
    }
    
}
