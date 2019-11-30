//
//  GPXElement.swift
//  GPXKit
//
//  Created by Vincent on 5/11/18.
//

import Foundation

/**
 A root class for all element types
 
 All element types such as waypoints, tracks or routes are subclasses of `GPXElement`.
 This class brings important methods that aids towards creation of a GPX file.

 - Note:
    This class should not be used as is. To use its functionalities, please subclass it instead.
 */
open class GPXElement: NSObject {
    
    // MARK:- Tag
    
    /// Tag name of the element.
    ///
    /// All subclasses must override this method, as elements cannot be tag-less.
    func tagName() -> String {
        fatalError("Subclass must override tagName()")
    }
    
    // MARK:- Instance
  
    /// Default Initializer
    public required override init() {
        super.init()
    }

    // MARK:- GPX
   
    /// for generating newly tracked data straight into a formatted `String` that holds formatted data according to GPX syntax
    open func gpx() -> String {
        let gpx = NSMutableString()
        self.gpx(gpx, indentationLevel: 0)
        return gpx as String
    }
    
    /// A method for invoking all tag-related methods
    func gpx(_ gpx: NSMutableString, indentationLevel: Int) {
        self.addOpenTag(toGPX: gpx, indentationLevel: indentationLevel)
        self.addChildTag(toGPX: gpx, indentationLevel: indentationLevel + 1)
        self.addCloseTag(toGPX: gpx, indentationLevel: indentationLevel)
    }
    
    /// Implements an open tag
    ///
    /// An open tag is added to overall gpx content.
    ///
    /// - Parameters:
    ///     - gpx: the GPX string
    ///     - indentationLevel: the amount of indentation required to add for the tag
    /// - **Example**:
    ///
    ///         <trk> // an open tag
    ///         <wpt lat=1.0 lon=2.0> // an open tag with extra attributes
    func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        gpx.append(String(format: "%@<%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName()))
    }
    
    /// Implements a child tag after an open tag, before a close tag.
    ///
    /// An child tag is added to overall gpx content.
    ///
    /// - Parameters:
    ///     - gpx: the GPX string
    ///     - indentationLevel: the amount of indentation required to add for the tag
    /// - **Example**:
    ///
    ///         <trkpt lat=4.0 lon=3.0> // an open tag
    ///             <ele>20.19</ele>    // a child tag
    ///         </trkpt>                // a close tag
    func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        // Override to subclasses
    }
    
    /// Implements a close tag
    ///
    /// An close tag is added to overall gpx content.
    ///
    /// - Parameters:
    ///     - gpx: the GPX string
    ///     - indentationLevel: the amount of indentation required to add for the tag
    /// - **Example**:
    ///
    ///         </metadata> // a close tag
    func addCloseTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        gpx.append(String(format: "%@</%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName()))
    }
    
    
    /// For adding `Int` type values to a child tag
    /// - Parameters:
    ///     - value: value of that particular child tag
    ///     - gpx: The GPX string
    ///     - tagName: The tag name of the child tag
    ///     - indentationLevel: the amount of indentation required
    ///
    /// - Without default value or attribute
    /// - Method should only be used when overriding `addChildTag(toGPX:indentationLevel:)`
    /// - Will not execute if `value` is nil.
    /// - **Example**:
    ///
    ///       <ele>100</ele> // 100 is an example value
    func addProperty(forIntegerValue value: Int?, gpx: NSMutableString, tagName: String, indentationLevel: Int) {
        if let validValue = value {
        addProperty(forValue: String(validValue), gpx: gpx, tagName: tagName, indentationLevel: indentationLevel, defaultValue: nil, attribute: nil)
        }
    }
    
    /// For adding `Double` type values to a child tag
    /// - Parameters:
    ///     - value: value of that particular child tag
    ///     - gpx: The GPX string
    ///     - tagName: The tag name of the child tag
    ///     - indentationLevel: the amount of indentation required
    ///
    /// - Without default value or attribute
    /// - Method should only be used when overriding `addChildTag(toGPX:indentationLevel:)`
    /// - Will not execute if `value` is nil.
    /// - **Example**:
    ///
    ///       <ele>100.21345</ele> // 100.21345 is an example value
    func addProperty(forDoubleValue value: Double?, gpx: NSMutableString, tagName: String, indentationLevel: Int) {
        if let validValue = value {
            addProperty(forValue: String(validValue), gpx: gpx, tagName: tagName, indentationLevel: indentationLevel, defaultValue: nil, attribute: nil)
        }
    }
    
    /// For adding `String` type values to a child tag
    /// - Parameters:
    ///     - value: value of that particular child tag
    ///     - gpx: The GPX string
    ///     - tagName: The tag name of the child tag
    ///     - indentationLevel: the amount of indentation required
    ///     - defaultValue: default value expected of the particular child tag
    ///     - attribute: an attribute of the tag
    ///
    /// - If default value is the same as `value` parameter, method will not execute.
    /// - Method should only be used when overriding `addChildTag(toGPX:indentationLevel:)`
    /// - **Example**:
    ///
    ///       <name attribute>Your Value Here</name>
    func addProperty(forValue value: String?, gpx: NSMutableString, tagName: String, indentationLevel: Int, defaultValue: String? = nil, attribute: String? = nil) {
        
        // value cannot be nil or empty
        if value == nil || value == "" {
            return
        }
        
        if defaultValue != nil && value == defaultValue {
            return
        }
        
        var isCDATA: Bool = false
        
        let match: Range? = value?.range(of: "[^a-zA-Z0-9.,+-/*!='\"()\\[\\]{}!$%@?_;: #\t\r\n]", options: .regularExpression, range: nil, locale: nil)
        
        // if match range, isCDATA == true
        if match != nil {
            isCDATA = true
        }
        
        // will append as XML CDATA instead.
        if isCDATA {
            gpx.appendFormat("%@<%@%@><![CDATA[%@]]></%@>\r\n", indent(forIndentationLevel: indentationLevel), tagName, (attribute != nil) ? " ".appending(attribute!): "", value?.replacingOccurrences(of: "]]>", with: "]]&gt;") ?? "", tagName)
        }
        else {
            gpx.appendFormat("%@<%@%@>%@</%@>\r\n", indent(forIndentationLevel: indentationLevel), tagName, (attribute != nil) ? " ".appending(attribute!): "", value ?? "", tagName)
        }
    }
    
    /// Indentation amount based on parameter
    ///
    /// - Parameters:
    ///     - indentationLevel: The indentation amount you require it to have.
    ///
    /// - Returns:
    ///     A `NSMutableString` that has been appended with amounts of "\t" with regards to indentation requirements input from the parameter.
    ///
    /// - **Example:**
    ///
    ///       This is unindented text (indentationLevel == 0)
    ///         This is indented text (indentationLevel == 1)
    ///             This is indented text (indentationLevel == 2)
    func indent(forIndentationLevel indentationLevel: Int) -> NSMutableString {
        let result = NSMutableString()
        
        for _ in 0..<indentationLevel {
            result.append("\t")
        }
        
        return result
    }
}
