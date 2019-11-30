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
public final class GPXExtensions: GPXElement, Codable {
    
    /// Extended children tags
    public var children = [GPXExtensionsElement]()
    
    // MARK:- Initializers
    
    /// Default Initializer.
    public required init() {
        super.init()
    }
    
    /// For initializing with a raw element. Parser use only.
    ///
    /// - Parameters:
    ///     - raw: parser's raw element
    init(raw: GPXRawElement) {
        super.init()
        for child in raw.children {
            let tmp = GPXExtensionsElement(name: child.name)
            tmp.text = child.text
            tmp.attributes = child.attributes
            children.append(tmp)
        }
        
    }
    
    // MARK:- Append and Retrieve
    
    /// Appending children tags to extension tag, easily.
    ///
    /// - Parameters:
    ///     - parent: parent tag's name. If you do not wish to have a parent tag, leave it as `nil`.
    ///     - contents: data to be represented as extended tag and values.
    public func append(at parent: String?, contents: [String : String]) {
        if let parent = parent {
            let parentElement = GPXExtensionsElement(name: parent)
            for (key, value) in contents {
                let element = GPXExtensionsElement(name: key)
                element.text = value
                parentElement.children.append(element)
            }
            children.append(parentElement)
        }
        else {
            for (key, value) in contents {
                let element = GPXExtensionsElement(name: key)
                element.text = value
                children.append(element)
            }
        }
    }
    
    /// Get a dictionary of data from a parent tag name, easily.
    ///
    /// - Parameters:
    ///     - parent: parent tag name, to retrieve from. Leave it as `nil` if parent tag should not be expected.
    public func get(from parent: String?) -> [String : String]? {
        var data = [String : String]()
        
        if let parent = parent {
            var hasChild = false
            for child in children {
                if child.name == parent {
                    data = child.attributes
                    
                    for child2 in child.children {
                        data[child2.name] = child2.text
                    }
                    hasChild = true
                }
            }
            if !hasChild {
                return nil
            }
        }
        else {
            guard let child = children.first else { return nil }
            data = child.attributes
            data[child.name] = child.text
        }
        
        return data
    }
    
    // MARK:- Subscript
    
    /**
     Access child element in extensions.
     
     If extended data does not have a parent tag, **i.e**:

            <extensions>
                <tag>50</tag>
            </extensions>
     
     Access it directly by `extensions["tag"]`, and access the text attribute of it.
     
     If extended data does not have a parent tag, **i.e**:
     
            <ParentTag>
                <Tag>80</Tag>
            </ParentTag>
     
     Access it directly by `extensions["ParentTag"]["tag"]`, and access the text attribute of it.
     
     - Parameters:
        - name: name of child tag.
     */
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
    
    // MARK:- Tag
    override func tagName() -> String {
        return "extensions"
    }
    
    // MARK:- Unavailable classes
    //        Have been removed.
    
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        for child in children {
            child.gpx(gpx, indentationLevel: indentationLevel)
        }

    }
}
