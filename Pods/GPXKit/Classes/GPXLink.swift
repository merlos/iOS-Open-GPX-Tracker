//
//  GPXLink.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import UIKit

/// A link to an external resource (Web page, digital photo, video clip, etc) with additional information.
open class GPXLink: GPXElement {
    
    // MARK:- Accessing Properties

    /// Text of hyperlink
    var text: String?
    
    /// Mime type of content (image/jpeg)
    var mimetype: String?
    
    /// URL of hyperlink
    var href: String?
   
    // MARK:- Instance
    
    override init() {
        self.text = String()
        self.mimetype = String()
        self.href = String()
        super.init()
    }
    
    override init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        self.text = String()
        self.mimetype = String()
        self.href = String()
        
        super.init(XMLElement: element, parent: parent)
        
        self.text = text(forSingleChildElement: "text", xmlElement: element)
        self.mimetype = text(forSingleChildElement: "type", xmlElement: element)
        self.href = text(forSingleChildElement: "href", xmlElement: element, required: true)
    }
    
    /// ---------------------------------
    /// @name Create Link
    /// ---------------------------------
    
    /** Creates and returns a new link element.
     @param href URL of hyperlink
     @return A newly created link element.
     */
    func link(with href: String) -> GPXLink {
        let link = GPXLink()
        link.href = href
        
        return link
    }
    
    // MARK:- Public Methods
    
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "link"
    }
   
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        
        if href != nil {
            attribute.appendFormat(" href=\"%@\"", href!)
        }
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName())
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: text as NSString?, gpx: gpx, tagName: "text", indentationLevel: indentationLevel)
        self.addProperty(forValue: mimetype as NSString?, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
    }

}
