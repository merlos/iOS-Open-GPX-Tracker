//
//  GPXExtensionsElement.swift
//  Pods
//
//  Created by Vincent on 14/7/19.
//

import Foundation

/// A duplicated class of `GPXRawElement`
///
/// This class is a public class as it is representative of all child extension tag types.
///
/// It is also inherits `GPXElement`, and therefore, works like any other 'native' element types.
open class GPXExtensionsElement: GPXElement, Codable {
    
    /// Tag name of extension element.
    public var name: String
    
    /// Text data content of the element.
    public var text: String?
    
    /// Attributes data of the element.
    public var attributes = [String : String]()
    
    /// Children tags of this element.
    public var children = [GPXExtensionsElement]()
    
    /// Easily get child tags via subscript.
    public subscript(name: String) -> GPXExtensionsElement {
        get {
            for child in children {
                if child.name == name {
                    return child
                }
            }
            return GPXExtensionsElement()
        }
    }
    
    /// Initialize with a tagName.
    public init(name: String) {
        self.name = name
        super.init()
    }
    
    /// Default initializer.
    required public init() {
        self.name = "Undefined"
    }
    
    // MARK:- GPX File Mutation
    
    override func tagName() -> String {
        return name
    }
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        for (key, value) in attributes {
            attribute.appendFormat(" %@=\"%@\"", key, value)
        }
        gpx.appendOpenTag(indentation: indent(forIndentationLevel: indentationLevel), tag: tagName(), attribute: attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        if let text = text {
            self.addProperty(forValue: text, gpx: gpx, tagName: tagName(), indentationLevel: indentationLevel)
        }
        for child in children {
            if let text = child.text {
                self.addProperty(forValue: text, gpx: gpx, tagName: child.tagName(), indentationLevel: indentationLevel)
            }
            else {
                child.gpx(gpx, indentationLevel: indentationLevel)
            }
        }
        
    }
}
