//
//  GPXCopyright.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import UIKit

open class GPXCopyright: GPXElement {
    var yearValue = String()
    
    var year: Date?
    var license: String?
    var author: String?
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    public init(author: String) {
        super.init()
        self.author = author
    }
    
    // MARK: Tag
    
    override func tagName() -> String! {
        return "copyright"
    }
    
    // MARK: GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        
        if author != nil {
            attribute.appendFormat(" author=\"%@\"", author!)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", tagName())
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        self.addProperty(forValue: GPXType().value(forDateTime: year!) as NSString, gpx: gpx, tagName: "year", indentationLevel: indentationLevel)
        self.addProperty(forValue: license as NSString?, gpx: gpx, tagName: "license", indentationLevel: indentationLevel)
    }
    
}
