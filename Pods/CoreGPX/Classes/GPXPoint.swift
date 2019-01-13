//
//  GPXPoint.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//

import UIKit

open class GPXPoint: GPXElement {

    var elevation: CGFloat? = CGFloat()
    var time: Date = Date()
    var latitude: CGFloat? = CGFloat()
    var longitude: CGFloat? = CGFloat()
    
    // MARK:- Instance
    
    required public init() {
        super.init()
    }
    
    public init(latitude: CGFloat, longitude: CGFloat) {
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
        
        self.addProperty(forNumberValue: elevation, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: GPXType().value(forDateTime: time) as NSString?, gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
    }
    
}
