//
//  GPXExtensions.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

open class GPXExtensions: GPXElement {
    
    // MARK:- Instance
    public required init() {
        super.init()
    }
    
    // MARK:- Tag
    override func tagName() -> String {
        return "extensions"
    }
    
    // MARK:- GPX
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
    }
}
