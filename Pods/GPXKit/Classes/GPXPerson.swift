//
//  GPXPerson.swift
//  GPXKit
//
//  Created by Vincent on 18/11/18.
//

import UIKit

open class GPXPerson: GPXElement {
    var name: String
    var email: GPXEmail?
    var link: GPXLink?
    
    
    // MARK:- Instance
    
    public required init() {
        name = String()
        email = GPXEmail()
        link = GPXLink()
        super.init()
    }
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        name = String()
        email = GPXEmail()
        link = GPXLink()
        
        super.init(XMLElement: element, parent: parent)
        
        name = text(forSingleChildElement: "name", xmlElement: element)
        email = childElement(ofClass: GPXEmail.self, xmlElement: element) as! GPXEmail?
        link = childElement(ofClass: GPXLink.self, xmlElement: element) as! GPXLink?
    }
    
    // MARK:- Public Methods
    
    
    
    // MARK:- Tag
    override func tagName() -> String! {
        return "person"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name as NSString, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        
        if email != nil {
            self.email?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        if link != nil {
            self.link?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}
