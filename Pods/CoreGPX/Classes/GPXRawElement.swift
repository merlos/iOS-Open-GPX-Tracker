//
//  ParserElement.swift
//  CoreGPX
//
//  Created by Vincent on 2/7/19.
//
//  Referenced from GitHub, yahoojapan/SwiftyXMLParser

import Foundation

/// Raw element that is for GPXParser to work with.
///
/// Should not be used as is, and should be disposed off once done with parsing.
final class GPXRawElement {
    
    /// name tag of element
    var name: String
    
    /// text contents of element
    var text: String?
    
    /// open tag attributes of element
    var attributes = [String : String]()
    
    /// child of element tag
    var children = [GPXRawElement]()
    
    /// init with name tag name
    init(name: String) {
        self.name = name
    }
}
