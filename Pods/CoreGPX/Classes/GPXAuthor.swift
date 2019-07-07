//
//  GPXAuthor.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import Foundation

/// Author type, holds information of the creator of the GPX file. A subclass of `GPXPerson`.
open class GPXAuthor: GPXPerson {
    
    /// Default Initializer
    public required init() {
        super.init()
    }
    
    /// Internal use only. For parsing use.
    override init(dictionary: [String : String]) {
        super.init(dictionary: dictionary)
    }
    
    // MARK: Tag
    
    override func tagName() -> String {
        return "author"
    }
}
