//
//  GPXBounds.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import UIKit

open class GPXBounds: GPXElement {

    var minLatitude: CGFloat? = CGFloat()
    var maxLatitude: CGFloat? = CGFloat()
    var minLongitude: CGFloat? = CGFloat()
    var maxLongitude: CGFloat? = CGFloat()
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    public init(minLatitude: CGFloat, maxLatitude: CGFloat, minLongitude: CGFloat, maxLongitude: CGFloat) {
        super.init()
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "bounds"
    }
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        
        if minLatitude != nil {
        attribute.appendFormat(" minlat=\"%f\"", minLatitude!)
        }
        if minLongitude != nil {
        attribute.appendFormat(" minlon=\"%f\"", minLongitude!)
        }
        if maxLatitude != nil {
        attribute.appendFormat(" maxlat=\"%f\"", maxLatitude!)
        }
        if maxLongitude != nil {
        attribute.appendFormat(" maxlon=\"%f\"", maxLongitude!)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel))
    }
    
}
