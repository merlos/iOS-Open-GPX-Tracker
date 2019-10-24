//
//  GPXAuthor.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import Foundation

/// Author type, holds information of the creator of the GPX file. A subclass of `GPXPerson`.
public final class GPXAuthor: GPXPerson {
    
    // MARK:- Initializers
    
    /// Default Initializer
    public required init() {
        super.init()
    }
    
    /// Inits native element from raw parser value
    override init(raw: GPXRawElement) {
        super.init(raw: raw)
    }
    
    /// Decoder handling (from superclass)
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "author"
    }
}
