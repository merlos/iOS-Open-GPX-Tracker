//
//  GPXElement.swift
//  GPXKit
//
//  Created by Vincent on 5/11/18.
//

import UIKit

open class GPXElement: NSObject {
    
    public var parent: GPXElement?
    //public var element: TBXMLElement
    public var element: UnsafeMutablePointer<TBXMLElement>? = nil
    
    //from GPXConst
    let kGPXInvalidGPXFormatNotification = "kGPXInvalidGPXFormatNotification"

    let kGPXDescriptionKey = "kGPXDescriptionKey"

    
    // MARK:- Tag
    
    func tagName() -> String! {
        return nil
    }
    func implementClasses() -> Array<Any>! {
        return nil
    }
    
    // MARK:- Instance
    /*
    convenience init(XMLElement element: UnsafeMutablePointer<TBXMLElement>, parent: GPXElement?) {
        self.init(XMLElement: element, parent: parent)
        self.parent = parent!
    }
 */
    public required override init() {
        //self.parent = GPXElement()
        //self.element = TBXMLElement()
        super.init()
    }
    
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        //self.element = TBXMLElement()
        self.element = element
        
        super.init()
    
        self.parent = self
        //element?.initialize(to: self.element)
        
    }
    
    
    // MARK:- Elements
    
    func value(ofAttribute name: String?, xmlElement: UnsafeMutablePointer<TBXMLElement>?) -> String? {
        return value(ofAttribute: name, xmlElement: xmlElement, required: false)
    }
    
    func value(ofAttribute name: String?, xmlElement: UnsafeMutablePointer<TBXMLElement>?, required: Bool) -> String? {
        let value = TBXML.value(ofAttributeNamed: name, for: xmlElement)
        
        if value != nil && required == true {
            
            let description = String(format: "%@ element require %@ attribute.", self.tagName(), name ?? "")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGPXInvalidGPXFormatNotification), object: self, userInfo: [kGPXDescriptionKey : description])
        }
        
        return value
    }
    
    func text(forSingleChildElement name: String?, xmlElement: UnsafeMutablePointer<TBXMLElement>?) -> String {
        
        return text(forSingleChildElement: name, xmlElement: xmlElement, required: false)
    }
    
    func text(forSingleChildElement name: String?, xmlElement: UnsafeMutablePointer<TBXMLElement>?, required: Bool) -> String! {
        
        if let element: UnsafeMutablePointer<TBXMLElement> = TBXML.childElementNamed(name, parentElement: xmlElement) {
            return TBXML.text(for: element)
        }
        else {
            if required {
                let description = String(format: "%@ element require %@ element.", self.tagName(), name ?? "")
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGPXInvalidGPXFormatNotification), object: self, userInfo: [kGPXDescriptionKey : description])
            }
        }
        
        return nil
    }
    
    func childElement(ofClass Class: GPXElement.Type, xmlElement: UnsafeMutablePointer<TBXMLElement>?) -> GPXElement? {
       
        return childElement(ofClass: Class, xmlElement: xmlElement, required: false)
    }
    
    func childElement(ofClass Class: GPXElement.Type, xmlElement: UnsafeMutablePointer<TBXMLElement>?, required: Bool) -> GPXElement? {
        let firstElement: GPXElement?
        let element: UnsafeMutablePointer<TBXMLElement>? = TBXML.childElementNamed(Class.init().tagName(), parentElement: xmlElement)
        
        
        firstElement = Class.init(XMLElement: element, parent: self)
        
        if element != nil {
            
            let secondElement: UnsafeMutablePointer<TBXMLElement>? = TBXML.nextSiblingNamed(Class.init().tagName(), searchFrom: element)
            if secondElement != nil {
                let description = String(format: "%@ element has more than two %@ elements.", self.tagName(), Class.init().tagName())
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGPXInvalidGPXFormatNotification), object: self, userInfo: [kGPXDescriptionKey : description])
            }
        }
        
        if required {
            if firstElement == nil {
                let description = String(format: "%@ element require %@ element.", self.tagName(), Class.init().tagName())
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGPXInvalidGPXFormatNotification), object: self, userInfo: [kGPXDescriptionKey : description])
            }
        }
        
        return firstElement
    }
    
    func childElement(Named name: String, Class: GPXElement.Type, xmlElement: UnsafeMutablePointer<TBXMLElement>?) -> GPXElement? {
        return childElement(ofClass: Class, xmlElement: xmlElement, required: false)
    }
    
    func childElement(Named name: String, Class: GPXElement.Type, xmlElement: UnsafeMutablePointer<TBXMLElement>?, required: Bool) -> GPXElement? {
        let firstElement: GPXElement?
        let element: UnsafeMutablePointer<TBXMLElement>? = TBXML.childElementNamed(name, parentElement: xmlElement)
        
        firstElement = Class.init(XMLElement: element!, parent: self)
        
        if element != nil {
            
            let secondElement: UnsafeMutablePointer<TBXMLElement>? = TBXML.nextSiblingNamed(name, searchFrom: element)
            if secondElement != nil {
                let description = String(format: "%@ element has more than two %@ elements.", self.tagName(), Class.init().tagName())
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGPXInvalidGPXFormatNotification), object: self, userInfo: [kGPXDescriptionKey : description])
            }
        }
        
        if required {
            if firstElement == nil {
                let description = String(format: "%@ element require %@ element.", self.tagName(), Class.init().tagName())
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGPXInvalidGPXFormatNotification), object: self, userInfo: [kGPXDescriptionKey : description])
            }
        }
        
        return firstElement
    }
    
    func childElement(ofClass Class: GPXElement.Type, xmlElement: UnsafeMutablePointer<TBXMLElement>?, eachBlock: @escaping (_ element: GPXElement?) -> Void) {
        var element: UnsafeMutablePointer<TBXMLElement>? = TBXML.childElementNamed(Class.init().tagName(), parentElement: xmlElement)
        
        while element != nil {
            eachBlock(Class.init(XMLElement: element!, parent: self))
            element = TBXML.nextSiblingNamed(Class.init().tagName(), searchFrom: element)
        }
    }
    
    // MARK:- GPX
   
    open func gpx() -> String {
        let gpx: NSMutableString = ""
        self.gpx(gpx, indentationLevel: 0)
        return gpx as String
    }
    
    func gpx(_ gpx: NSMutableString, indentationLevel: Int) {
        self.addOpenTag(toGPX: gpx, indentationLevel: indentationLevel)
        self.addChildTag(toGPX: gpx, indentationLevel: indentationLevel + 1)
        self.addCloseTag(toGPX: gpx, indentationLevel: indentationLevel)
    }
    
    func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        gpx.append(String(format: "%@<%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName()))
    }
    
    func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        // Override to subclasses
    }
    
    func addCloseTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        gpx.append(String(format: "%@</%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName()))
    }
    
    func addProperty(forValue value: NSString?, gpx: NSMutableString, tagName: NSString, indentationLevel: Int) {
        addProperty(forValue: value, gpx: gpx, tagName: tagName, indentationLevel: indentationLevel, defaultValue: nil, attribute: nil)
    }
    
    func addProperty(forNumberValue value: CGFloat?, gpx: NSMutableString, tagName: NSString, indentationLevel: Int) {
        if value != nil && value != 0 {
        addProperty(forValue: NSString(format: "%f", value!), gpx: gpx, tagName: tagName, indentationLevel: indentationLevel, defaultValue: nil, attribute: nil)
        }
    }
    
    func addProperty(forValue value: NSString?, gpx: NSMutableString, tagName: NSString, indentationLevel: Int, attribute: String?) {
        addProperty(forValue: value, gpx: gpx, tagName: tagName, indentationLevel: indentationLevel, defaultValue: nil, attribute: attribute)
    }
    
    func addProperty(forValue value: NSString?, gpx: NSMutableString, tagName: NSString, indentationLevel: Int, defaultValue: NSString?) {
        addProperty(forValue: value, gpx: gpx, tagName: tagName, indentationLevel: indentationLevel, defaultValue: defaultValue, attribute: nil)
    }
    
    func addProperty(forValue value: NSString?, gpx: NSMutableString, tagName: NSString, indentationLevel: Int, defaultValue: NSString?, attribute: String?) {
        if value == nil || value == "" {
            return
        }
        
        if defaultValue != nil && value == defaultValue {
            return
        }
        
        var outputCDMA: Bool = false
        
        let match: NSRange = (value?.range(of: "[^a-zA-Z0-9.,+-/*!='\"()\\[\\]{}!$%@?_;: #\t\r\n]", options: .regularExpression))!
        
        if match.location != NSNotFound {
            outputCDMA = true
        }
        
        if outputCDMA {
            gpx.appendFormat("%@<%@%@><![CDATA[%@]]></%@>\r\n", indent(forIndentationLevel: indentationLevel), tagName, (attribute != nil) ? " ".appending(attribute!): "", value?.replacingOccurrences(of: "]]>", with: "]]&gt;") ?? "", tagName)
        }
        else {
            gpx.appendFormat("%@<%@%@>%@</%@>\r\n", indent(forIndentationLevel: indentationLevel), tagName, (attribute != nil) ? " ".appending(attribute!): "", value ?? "", tagName)
        }
    }
    
    func indent(forIndentationLevel indentationLevel: Int) -> NSMutableString {
        let result: NSMutableString = ""
        
        for _ in 0..<indentationLevel {
            result.append("\t")
        }
        
        return result
    }
}
