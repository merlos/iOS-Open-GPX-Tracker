//
//  GPXEmail.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import Foundation

/**
 Used for handling email types
 
 Email is seperated as two variables in order to prevent email harvesting. The GPX v1.1 schema requires that.
 
 For example, an email of **"yourname@thisisawebsite.com"**, would have an id of **'yourname'** and a domain of **'thisisawebsite.com'**.
 */
open class GPXEmail: GPXElement {
    
    /// Email ID refers to the front part of the email address, before the **@**
    public var emailID: String?
    
    /// Domain refers to the back part of the email address, after the **@**
    public var domain: String?
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    /// Initialize with a full email address.
    ///
    /// Seperation to id and domain will be done by this class itself.
    ///
    /// - Parameters:
    ///     - email: A full email address. (example: 'name@domain.com')
    public init(withFullEmailAddress email: String) {
        let splitedEmail = email.components(separatedBy: "@")
        self.emailID = splitedEmail[0]
        self.domain = splitedEmail[1]
    }
    

    /// For internal use only
    ///
    /// Initializes a waypoint through a dictionary, with each key being an attribute name.
    ///
    /// - Remark:
    /// This initializer is designed only for use when parsing GPX files, and shouldn't be used in other ways.
    ///
    /// - Parameters:
    ///     - dictionary: a dictionary with a key of an attribute, followed by the value which is set as the GPX file is parsed.
    ///
    init(dictionary: [String : String]) {
        self.emailID = dictionary["id"]
        self.domain = dictionary["domain"]
    }
    
    // MARK:- Tag
    override func tagName() -> String {
        return "email"
    }
    
    // MARK:- GPX
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        if let emailID = emailID {
            attribute.appendFormat(" id=\"%@\"", emailID)
        }
        if let domain = domain {
            attribute.appendFormat(" domain=\"%@\"", domain)
        }
        gpx.appendOpenTag(indentation: indent(forIndentationLevel: indentationLevel), tag: tagName(), attribute: attribute)
    }
}
