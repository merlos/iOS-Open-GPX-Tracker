//
//  GPXLink.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/// A link to an external resource (Web page, digital photo, video clip, etc) with additional information.
open class GPXLink: GPXElement {
    
    // MARK:- Accessing Properties

    /// Text of hyperlink
    public var text: String?
    
    /// Mime type of content (image/jpeg)
    public var mimetype: String?
    
    /// URL of hyperlink
    public var href: String?
   
    // MARK:- Instance
    
    public required init() {
        self.text = String()
        self.mimetype = String()
        self.href = String()
        super.init()
    }
    
    /// ---------------------------------
    /// @name Create Link
    /// ---------------------------------
    
    /** Creates and returns a new link element.
     @param href URL of hyperlink
     @return A newly created link element.*/
    public init(withHref href: String) {
        self.href = href
        self.mimetype = String()
        self.text = String()
    }
    
    init(dictionary: [String : String]) {
        self.href = dictionary["href"]
        self.mimetype = dictionary["mimetype"]
        self.text = dictionary["text"]
    }
    
    
    // MARK:- Public Methods
    
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "link"
    }
   
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        if let href = href {
            attribute.appendFormat(" href=\"%@\"", href)
        }
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName())
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: text, gpx: gpx, tagName: "text", indentationLevel: indentationLevel)
        self.addProperty(forValue: mimetype, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
    }
}
