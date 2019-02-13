//
//  GPXPoint.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//
//  WARNING: Looks suspiciously broken

import Foundation

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
        self.latitude = number(from: dictionary["lat"])
        self.longitude = number(from: dictionary["lon"])
        self.elevation = number(from: dictionary["ele"])
        self.time = ISO8601DateParser.parse(dictionary["time"])
    }
    
    func number(from string: String?) -> Double? {
        guard let NonNilString = string else {
            return nil
        }
        return Double(NonNilString)
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
        self.addProperty(forValue: GPXType().value(forDateTime: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
    }
    
}
