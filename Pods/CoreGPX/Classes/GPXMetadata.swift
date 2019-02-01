//
//  GPXMetadata.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import UIKit

open class GPXMetadata: GPXElement {
    
    var name: String?
    var desc: String?
    var author: GPXAuthor?
    var copyright: GPXCopyright?
    var link: GPXLink?
    var time = Date()
    var keyword: String?
    var bounds: GPXBounds?
    var extensions: GPXExtensions?
    
    
    // MARK:- Instance
    
    required public init() {
        author = GPXAuthor()

        super.init()
    }
    
    // MARK:- Internal Methods
    
    func set(date: String) {
        if date.isEmpty == false {
            self.time = GPXType().dateTime(value: date) ?? Date()
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "metadata"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        
        if author != nil {
            self.author!.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if copyright != nil {
            self.copyright?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if link != nil {
            self.link?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: GPXType().value(forDateTime: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel, defaultValue: "0")
        self.addProperty(forValue: keyword, gpx: gpx, tagName: "keyword", indentationLevel: indentationLevel)
        
        if bounds != nil {
            self.bounds?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}
