//
//  GPXLink.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/// Some common web extensions used for `init(withURL:)`
fileprivate let kCommonWebExtensions: Set = ["htm", "html", "asp", "aspx", "jsp", "jspx", "do", "js", "php", "php3", "php4", "cgi", ".htaccess"]

/**
 A value type that can hold a web link to a external resource, or external information about a certain attribute.
 
 In addition to having a URL as its attribute, it also accepts the following as child tag:
    - type of content
    - text of web link (probably a description kind of thing)
 */
public final class GPXLink: GPXElement, Codable {
    
    /// For Codable use
    private enum CodingKeys: String, CodingKey {
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
   
    // MARK:- Initializers
    
    /// Default Initializer.
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
        guard let isFileURL = url?.isFileURL else { return }
        if !isFileURL {
            self.href = url?.absoluteString
            guard let pathExtension = url?.pathExtension else { return }
            // may not work if web extension is not shown. (etc, using .htaccess)
            if kCommonWebExtensions.contains(pathExtension) {
                self.mimetype = "Website"
            }
        }
    }
    
    /// Inits native element from raw parser value
    ///
    /// - Parameters:
    ///     - raw: Raw element expected from parser
    init(raw: GPXRawElement) {
        for child in raw.children {
            switch child.name {
            case "type":    self.mimetype = child.text
            case "text":    self.text = child.text
            default: continue
            }
        }
        self.href = raw.attributes["href"]
    }
    
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
        gpx.appendOpenTag(indentation: indent(forIndentationLevel: indentationLevel), tag: tagName(), attribute: attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: text, gpx: gpx, tagName: "text", indentationLevel: indentationLevel)
        self.addProperty(forValue: mimetype, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
    }
}
