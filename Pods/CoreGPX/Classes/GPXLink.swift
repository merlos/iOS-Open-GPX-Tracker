//
//  GPXLink.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/**
 A value type that can hold a web link to a external resource, or external information about a certain attribute.
 
 In addition to having a URL as its attribute, it also accepts the following as child tag:
    - type of content
    - text of web link (probably a description kind of thing)
 */
open class GPXLink: GPXElement, Codable {
    
    enum CodingKeys: String, CodingKey {
        case text
        case mimetype = "type"
        case href
    }
    
    // MARK:- Properties

    /// Text of hyperlink
    public var text: String?
    
    /// Mime type of content (image/jpeg)
    public var mimetype: String?
    
    /// URL of hyperlink
    public var href: String?
    
    /// Some common web extensions used for `init(withURL:)`
    private let commonWebExtensions = ["htm", "html", "asp", "aspx", "php", "cgi", ".htaccess"]
   
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    /// Initializes with a web link attribute
    ///
    /// - Parameters:
    ///     - href: **Hypertext Reference**. Basically, a web link which can be considered as a reference to whichever content, including metadata, waypoints, for example.
    ///
    public init(withHref href: String) {
        self.href = href
        self.mimetype = String()
        self.text = String()
    }
    
    /// Initializes with a URL.
    ///
    /// This initializer is similar to `init(withHref:)`, except, this method checks on whether if the input URL is valid or not. It also modifies the `type` attribute as 'Website' if identified to have a web page extension.
    ///
    /// - Parameters:
    ///     - url: input URL, intended as a web link reference.
    public init(withURL url: URL?) {
        guard let isURL = url?.isFileURL else { return }
        if isURL {
            self.href = url?.absoluteString
            guard let pathExtension = url?.pathExtension else { return }
            // may not work if web extension is not shown. (etc, using .htaccess)
            if commonWebExtensions.contains(pathExtension) {
                self.mimetype = "Website"
            }
        }
    }
    
    /// For internal use only
    ///
    /// Initializes a waypoint through a dictionary, with each key being an attribute name.
    ///
    /// - Remark:
    /// This initializer is designed only for use when parsing GPX files, and shouldn't be used in other ways.
    ///
    /// - Parameters:
    ///     - dictionary: a dictionary with a key of an attribute, followed by the value which is set as the GPX file is parsed.
    ///
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
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: text, gpx: gpx, tagName: "text", indentationLevel: indentationLevel)
        self.addProperty(forValue: mimetype, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
    }
}
