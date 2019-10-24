//
//  NSMutableString+XML.swift
//  CoreGPX
//
//  Created by Vincent Neo on 6/6/19.
//

import Foundation

/**
 To ensure that all appended tags are appended with the right formats.
 
 For both open and close tags.
 */
extension NSMutableString {
    
    /// Appends an open tag
    ///
    /// This function will append an open tag with the right format.
    ///
    /// **Format it will append to:**
    ///
    ///     "%@<%@%@>\r\n"
    ///     //indentations <tagName attributes> \r\n
    func appendOpenTag(indentation: NSMutableString, tag: String, attribute: NSMutableString) {
        self.appendFormat("%@<%@%@>\r\n", indentation, tag, attribute)
    }
    
    /// Appends a close tag
    ///
    /// This function will append an close tag with the right format.
    /// Not currently used, but included, for ease of use when needed.
    ///
    /// **Format it will append to:**
    ///
    ///     "%@</%@>\r\n"
    ///     //indentations </tagName> \r\n
    func appendCloseTag(indentation: NSMutableString, tag: String) {
        self.appendFormat("%@</%@>\r\n", indentation, tag)
    }
    
    /// Appends attributes to a tag
    func appendAttributeTag(_ attribution: String, value: CVarArg) {
        self.appendFormat(" %@=\"%@\"", attribution, value)
    }
}
