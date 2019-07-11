//
//  GPXExtensions.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/**
 For adding/obtaining data stored as extensions in GPX file.
 
 Typical GPX extended data, would have data that should be inbetween the open and close tags of **\<extensions>**
 
 This class represents the extended data in a GPX file.
 */
open class GPXExtensions: GPXElement, Codable {
    
    /// for attributes without parent tags
    private var rootAttributes = [String : String]()
    
    /// for attributes with parent tags
    private var childAttributes = [String : [String : String]]()
    
    // MARK:- Initializers
    
    /// Default Initializer.
    public required init() {
        super.init()
    }
    
    /// for parsing uses only. Internal Initializer.
    init(dictionary: [String : String]) {
        var dictionary = dictionary
        var attributes = [[String : String]]()
        var elementNames = [Int : String]()
        
        for key in dictionary.keys {
            let keySegments = key.components(separatedBy: ", ")
            if keySegments.count == 2 {
                let index = Int(keySegments[1])!
                let elementName = keySegments[0]
                let value = dictionary[key]
                
                while !attributes.indices.contains(index) {
                    attributes.append([String : String]())
                }
                
                if value == "internalParsingIndex \(index)" {
                    elementNames[index] = elementName
                }
                else {
                    attributes[index][elementName] = value
                }
            }
            // ignore any key that does not conform to GPXExtension's parsing naming convention.
        }
        if elementNames.isEmpty {
            rootAttributes = attributes[0]
        }
        else {
            for elementNameIndex in elementNames.keys {
                let value = elementNames[elementNameIndex]!
                childAttributes[value] = attributes[elementNameIndex]
            }
        }
        
    }
    
    // MARK:- Subscript
    
    /**
    Access/Write dictionaries in extensions this way.
     
     If extended data does not have a parent tag, **i.e**:
     
        <Tag>50</Tag>
     Access it via `extensions[nil]`, to get value of **["Tag" : "50"]**.
     Write it via `extensions[nil]` = **["Tag" : "50"]**.
     
     If extended data does not have a parent tag, **i.e**:
     
        <ParentTag>
            <Tag>50</Tag>
        </ParentTag>
     Access it via `extensions["ParentTag"]`, to get value of **["Tag" : "50"]**.
     Write it via `extensions["ParentTag"]` = **["Tag" : "50"]**.
     
     - Parameters:
        - parentTag: **nil** if no parent tag, if not, insert parent tag name here.
    */
    public subscript(parentTag: String?) -> [String : String]? {
        get {
            guard let parentTag = parentTag else {
                return rootAttributes
            }
            return childAttributes[parentTag]
        }
        set {
            guard let newValue = newValue else { return }
            guard let parentTag = parentTag else {
                rootAttributes = newValue
                return
            }
            childAttributes[parentTag] = newValue
        }
    }
    
    // MARK:- Tag
    override func tagName() -> String {
        return "extensions"
    }
    
    // MARK:- For Creation
    
    /// Insert a dictionary of extension objects
    ///
    /// - Parameters:
    ///     - tag: Parent Tag. If inserting without the parent tag, this value should be `nil`
    ///     - contents: Contents as a dictionary to be inserted to this object.
    public func insert(withParentTag tag: String?, withContents contents: [String : String]) {
        guard let tag = tag else {
            self.rootAttributes = contents
            return
        }
        self.childAttributes[tag] = contents
    }
    
    /// Remove a dictionary of extension objects
    ///
    /// - Parameters:
    ///     - tag: Parent Tag of contents for removal. If removing without the parent tag, this value should be `nil`
    public func remove(contentsOfParentTag tag: String?) {
        guard let tag = tag else {
            self.rootAttributes.removeAll()
            return
        }
        self.childAttributes[tag] = nil
    }
    
    // MARK:- GPX
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)

        for key in rootAttributes.keys {
            gpx.appendFormat("%@<%@>%@</%@>\r\n", indent(forIndentationLevel: indentationLevel + 1), key, rootAttributes[key] ?? "", key)
        }
        
        for key in childAttributes.keys {
            let newIndentationLevel = indentationLevel + 1
            gpx.append(String(format: "%@<%@>\r\n", indent(forIndentationLevel: newIndentationLevel), key))
            for childKey in childAttributes[key]!.keys {
                gpx.appendFormat("%@<%@>%@</%@>\r\n", indent(forIndentationLevel: newIndentationLevel + 1), childKey, childAttributes[key]![childKey] ?? "", childKey)
            }
            gpx.append(String(format: "%@</%@>\r\n", indent(forIndentationLevel: newIndentationLevel), key))
        }
        
    }
}
