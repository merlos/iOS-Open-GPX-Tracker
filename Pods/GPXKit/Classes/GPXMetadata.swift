//
//  GPXMetadata.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import UIKit

open class GPXMetadata: GPXElement {
    var timeValue: String
    var name: String?
    var desc: String?
    var author: GPXAuthor?
    var copyright: GPXCopyright?
    var link: GPXLink?
    var date: Date?
    var keyword: String?
    var bounds: GPXBounds?
    var extensions: GPXExtensions?
    
    
    // MARK:- Instance
    
    required public init() {
        author = GPXAuthor()
        timeValue = String()
        
        super.init()
    }
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        author = GPXAuthor()
        timeValue = String()
        
        super.init(XMLElement: element, parent: parent)
        
        name = text(forSingleChildElement: "name", xmlElement: element)
        desc = text(forSingleChildElement: "desc", xmlElement: element)
        author = childElement(ofClass: GPXAuthor.self, xmlElement: element) as? GPXAuthor
        copyright = childElement(ofClass: GPXCopyright.self, xmlElement: element) as? GPXCopyright
        link = childElement(ofClass: GPXLink.self, xmlElement: element) as? GPXLink
        timeValue = text(forSingleChildElement: "time", xmlElement: element)
        keyword = text(forSingleChildElement: "keyword", xmlElement: element)
        bounds = childElement(ofClass: GPXBounds.self, xmlElement: element) as? GPXBounds
        extensions = childElement(ofClass: GPXExtensions.self, xmlElement: element) as? GPXExtensions
        
    }
    
    // MARK:- Public Methods
    
    var time: Date? {
        return GPXType().dateTime(value: timeValue)
    }
    
    func set(time: Date) {
        timeValue = GPXType().value(forDateTime: time)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "metadata"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        addProperty(forValue: name as NSString?, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        addProperty(forValue: desc as NSString?, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        
        if author != nil {
            self.author!.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if copyright != nil {
            self.copyright?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if link != nil {
            self.link?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        addProperty(forValue: timeValue as NSString, gpx: gpx, tagName: "time", indentationLevel: indentationLevel, defaultValue: "0")
        addProperty(forValue: keyword as NSString?, gpx: gpx, tagName: "keyword", indentationLevel: indentationLevel)
        
        if bounds != nil {
            self.bounds?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}
