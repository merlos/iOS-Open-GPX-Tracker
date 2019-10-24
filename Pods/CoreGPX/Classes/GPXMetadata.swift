//
//  GPXMetadata.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import Foundation

/**
 A value type that represents the metadata header of a GPX file.
 
 Information about the GPX file should be stored here.
 - Supported Info types:
    - Name
    - Description
    - Author Info
    - Copyright
    - Date and Time
    - Keyword
    - Bounds
    - Also supports extensions
 */
public final class GPXMetadata: GPXElement, Codable {
    
    /// Name intended for the GPX file.
    public var name: String?
    
    /// Description about what the GPX file is about.
    public var desc: String?
    
    /// Author, or the person who created the GPX file.
    ///
    /// Includes other information regarding the author (see `GPXAuthor`)
    public var author: GPXAuthor?
    
    /// Copyright of the file, if required.
    public var copyright: GPXCopyright?
    
    /// A web link, usually one with information regarding the GPX file.
    public var link: GPXLink?
    
    /// Date and time of when the GPX file is created.
    public var time: Date?
    
    /// Keyword of the GPX file.
    public var keyword: String?

    /// Boundaries of coordinates of the GPX file.
    public var bounds: GPXBounds?
    
    /// Extensions to standard GPX, if any.
    public var extensions: GPXExtensions?
    
    
    // MARK:- Initializers
    
    /// Default initializer.
    required public init() {
        self.time = Date()
        super.init()
    }
    
    /// Inits native element from raw parser value
    ///
    /// - Parameters:
    ///     - raw: Raw element expected from parser
    init(raw: GPXRawElement) {
        super.init()
        for child in raw.children {
            let text = child.text
            
            switch child.name {
            case "name":        self.name = text
            case "desc":        self.desc = text
            case "author":      self.author = GPXAuthor(raw: child)
            case "copyright":   self.copyright = GPXCopyright(raw: child)
            case "link":        self.link = GPXLink(raw: child)
            case "time":        self.time = GPXDateParser.parse(date: text)
            case "keywords":    self.keyword = text
            case "bounds":      self.bounds = GPXBounds(raw: child)
            case "extensions":  self.extensions = GPXExtensions(raw: child)
            default: continue
            }
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "metadata"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        
        if author != nil {
            self.author?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if copyright != nil {
            self.copyright?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if link != nil {
            self.link?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: Convert.toString(from: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel, defaultValue: "0")
        self.addProperty(forValue: keyword, gpx: gpx, tagName: "keyword", indentationLevel: indentationLevel)
        
        if bounds != nil {
            self.bounds?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
