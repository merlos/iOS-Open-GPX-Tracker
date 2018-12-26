//
//  GPXPoint.swift
//  GPXKit
//
//  Created by Vincent on 23/11/18.
//

import UIKit

open class GPXPoint: GPXElement {

    var elevationValue: String?
    var timeValue: String?
    var latitudeValue: String?
    var longitudeValue: String?
    
    var elevation: CGFloat?
    var time: Date?
    var latitude: CGFloat?
    var longitude: CGFloat?
    
    // MARK:- Instance
    
    required public init() {
        super.init()
    }
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        super.init(XMLElement: element, parent: parent)
        
        elevationValue = text(forSingleChildElement: "ele", xmlElement: element)
        timeValue = text(forSingleChildElement: "time", xmlElement: element)
        latitudeValue = text(forSingleChildElement: "lat", xmlElement: element, required: true)
        longitudeValue = text(forSingleChildElement: "lon", xmlElement: element, required: true)
        
        elevation = GPXType().decimal(elevationValue)
        time = GPXType().dateTime(value: timeValue!)
        latitude = GPXType().latitude(latitudeValue)
        longitude = GPXType().longitude(longitudeValue)

    }
    
    func point(with latitude: CGFloat, longitude: CGFloat) -> GPXPoint {
        let point = GPXPoint()
        
        point.latitude = latitude
        point.longitude = longitude
        
        return point
    }
    
    // MARK:- Public Methods
    
    func set(elevation: CGFloat) {
        elevationValue = GPXType().value(forDecimal: elevation)
    }
    
    func set(time: Date) {
        timeValue = GPXType().value(forDateTime: time)
    }
    
    func set(latitude: CGFloat) {
        latitudeValue = GPXType().value(forLatitude: latitude)
    }
    
    func set(longitude: CGFloat) {
        longitudeValue = GPXType().value(forLongitude: longitude)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "pt"
    }
    
    // MARK: GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        if latitudeValue != nil {
            attribute.appendFormat(" lat=\"%@\"", latitudeValue!)
        }
        if longitudeValue != nil {
            attribute.appendFormat(" lon=\"%@\"", longitudeValue!)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: elevationValue as NSString?, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: timeValue as NSString?, gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
    }
    
}
