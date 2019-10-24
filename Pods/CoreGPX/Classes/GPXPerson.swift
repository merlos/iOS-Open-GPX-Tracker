//
//  GPXPerson.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/// A value type that is designated to hold information regarding the person or organisation who has created the GPX file.
public class GPXPerson: GPXElement, Codable {
    
    /// Name of person who has created the GPX file.
    public var name: String?
    
    /// The email address of the person who has created the GPX file.
    public var email: GPXEmail?
    
    /// An external website that holds information on the person who has created the GPX file. Additional information may be supported as well.
    public var link: GPXLink?
    
    // MARK:- Initializers
    
    // Default Initializer.
    public required init() {
        super.init()
    }
    
    /// Inits native element from raw parser value
    ///
    /// - Parameters:
    ///     - raw: Raw element expected from parser
    init(raw: GPXRawElement) {
        for child in raw.children {
            switch child.name {
            case "name": self.name = child.text
            case "email": self.email = GPXEmail(raw: child)
            case "link": self.link = GPXLink(raw: child)
            default: continue
            }
        }
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "person"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        
        if email != nil {
            self.email?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if link != nil {
            self.link?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
