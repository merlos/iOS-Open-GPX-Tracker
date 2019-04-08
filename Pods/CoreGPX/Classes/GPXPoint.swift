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
open class GPXPoint: GPXElement {

    public var elevation: Double?
    public var time: Date?
    public var latitude: Double?
    public var longitude: Double?
    
    // MARK:- Instance
    
    required public init() {
        super.init()
    }
    
    public init(latitude: Double, longitude: Double) {
        super.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(dictionary: [String : String]) {
        super.init()
        self.latitude = Convert.toDouble(from: dictionary["lat"])
        self.longitude = Convert.toDouble(from: dictionary["lon"])
        self.elevation = Convert.toDouble(from: dictionary["ele"])
        self.time = ISO8601DateParser.parse(dictionary["time"])
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "pt"
    }
    
    // MARK: GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        if let latitude = latitude {
            attribute.appendFormat(" lat=\"%f\"", latitude)
        }
        if let longitude = longitude {
            attribute.appendFormat(" lon=\"%f\"", longitude)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forDoubleValue: elevation, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: Convert.toString(from: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
    }
    
}
