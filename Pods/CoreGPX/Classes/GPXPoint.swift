//
//  GPXPoint.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//
//  WARNING: Looks suspiciously broken

import UIKit

open class GPXPoint: GPXElement {

    var elevation: Double? = Double()
    var time: Date = Date()
    var latitude: Double? = Double()
    var longitude: Double? = Double()
    
    // MARK:- Instance
    
    required public init() {
        super.init()
    }
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "pt"
    }
    
    // MARK: GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        if latitude != nil {
            attribute.appendFormat(" lat=\"%f\"", latitude!)
        }
        if longitude != nil {
            attribute.appendFormat(" lon=\"%f\"", longitude!)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forDoubleValue: elevation, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: GPXType().value(forDateTime: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
    }
    
}
