//
//  GPXPerson.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/// A value type that is designated to hold information regarding the person or organisation who has created the GPX file.
open class GPXPerson: GPXElement {
    
    /// Name of person who has created the GPX file.
    public var name: String?
    /// The email address of the person who has created the GPX file.
    public var email: GPXEmail?
    
    /// An external website that holds information on the person who has created the GPX file. Additional information may be supported as well.
    public var link: GPXLink?
    
    // MARK:- Instance
    
    // Default Initializer.
    public required init() {
        super.init()
    }
    
    /// For internal use only
    ///
    /// Initializes through a dictionary, with each key being an attribute name.
    ///
    /// - Remark:
    /// This initializer is designed only for use when parsing GPX files, and shouldn't be used in other ways.
    ///
    /// - Parameters:
    ///     - dictionary: a dictionary with a key of an attribute, followed by the value which is set as the GPX file is parsed.
    ///
    init(dictionary: [String : String]) {
        name = dictionary["name"]
        super.init()
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
