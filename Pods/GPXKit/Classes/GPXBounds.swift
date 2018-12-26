//
//  GPXBounds.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import UIKit

open class GPXBounds: GPXElement {

    var minLatitudeValue: String?
    var minLongitudeValue: String?
    var maxLatitudeValue: String?
    var maxLongitudeValue: String?
    
    var minLatitude = CGFloat()
    var maxLatitude = CGFloat()
    var minLongitude = CGFloat()
    var maxLongitude = CGFloat()
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }

    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
        
        minLatitudeValue = value(ofAttribute: "minlat", xmlElement: element, required: true)
        maxLatitudeValue = value(ofAttribute: "minlon", xmlElement: element, required: true)
        minLongitudeValue = value(ofAttribute: "maxlat", xmlElement: element, required: true)
        maxLatitudeValue = value(ofAttribute: "maxlon", xmlElement: element, required: true)
        
        minLatitude = GPXType().latitude(minLatitudeValue)
        minLongitude = GPXType().longitude(minLongitudeValue)
        maxLatitude = GPXType().latitude(maxLatitudeValue)
        maxLongitude = GPXType().longitude(maxLatitudeValue)
    }
    
    func boundsWith(_ minLatitude: CGFloat, maxLatitude: CGFloat, minLongitude: CGFloat, maxLongitude: CGFloat) -> GPXBounds {
        
        let bounds = GPXBounds()
        
        bounds.minLatitude = minLatitude
        bounds.maxLatitude = maxLatitude
        bounds.minLongitude = minLongitude
        bounds.maxLongitude = maxLongitude
        
        return bounds
    }
    
    // MARK:- Public Methods
    
    func set(minLatitude: CGFloat) {
        minLatitudeValue = GPXType().value(forLatitude: minLatitude)
    }
    
    func set(minLongitude: CGFloat) {
        minLongitudeValue = GPXType().value(forLongitude: minLongitude)
    }
    
    func set(maxLatitude: CGFloat) {
        maxLatitudeValue = GPXType().value(forLatitude: maxLatitude)
    }
    
    func set(maxLongitude: CGFloat) {
        maxLongitudeValue = GPXType().value(forLongitude: maxLongitude)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "bounds"
    }
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        
        if minLatitudeValue != nil {
            attribute.appendFormat(" minlat=\"%@\"", minLatitudeValue!)
        }
        if minLongitudeValue != nil {
            attribute.appendFormat(" minlon=\"%@\"", minLongitudeValue!)
        }
        if maxLatitudeValue != nil {
            attribute.appendFormat(" maxlat=\"%@\"", maxLatitudeValue!)
        }
        if maxLongitudeValue != nil {
            attribute.appendFormat(" maxlon=\"%@\"", maxLongitudeValue!)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel))
    }
    
}
