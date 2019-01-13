//
//  GPXEmail.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import UIKit

/// An email address. Broken into two parts (id and domain) to help prevent email harvesting.
open class GPXEmail: GPXElement {
    var emailID: String?
    var domain: String?
    
    // MARK:- Instance
    
    public required init() {
        self.emailID = String()
        self.domain = String()
        super.init()
    }
    
    public init(emailID: String, domain: String) {
        self.emailID = emailID
        self.domain = domain
    }
    
    // MARK:- Tag
    override func tagName() -> String! {
        return "email"
    }
    
    // MARK:- GPX
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        
        if emailID != nil {
            attribute.appendFormat(" id=\"%@\"", emailID!)
        }
        if domain != nil {
            attribute.appendFormat(" domain=\"%@\"", domain!)
        }
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
 
}
