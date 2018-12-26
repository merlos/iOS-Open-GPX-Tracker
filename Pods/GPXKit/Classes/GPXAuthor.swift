//
//  GPXAuthor.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import UIKit

open class GPXAuthor: GPXPerson {
    
    public required init() {
        super.init()
    }
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
    }
    
    // MARK: Tag
    override func tagName() -> String! {
        return "author"
    }

}
