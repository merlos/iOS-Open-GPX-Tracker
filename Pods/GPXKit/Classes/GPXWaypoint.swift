//
//  GPXWaypoint.swift
//  GPXKit
//
//  Created by Vincent on 19/11/18.
//

import UIKit

open class GPXWaypoint: GPXElement {
    var elevationValue = String()
    var timeValue = String()
    var magneticVariationValue = String()
    var geoidHeightValue = String()
    var links = NSMutableArray()
    var fixValue = String()
    var satellitesValue = String()
    var horizontalDilutionValue = String()
    var verticalDilutionValue = String()
    var positionDilutionValue = String()
    var ageOfDGPSDataValue = String()
    var DGPSidValue = String()
    var latitudeValue:String?
    var longitudeValue:String?
    
    //var elevation = CGFloat()
    //var time = Date()
    //public var magneticVariation = CGFloat()
    //var geoidHeight = CGFloat()
    public var name = String()
    public var comment = String()
    public var desc = String()
    public var source = String()
    //var links = NSArray()
    public var symbol = String()
    public var type = String()
    //var fix = Int()
    //var satellites = Int()
    //var horizontalDilution = CGFloat()
    //var positionDilution = CGFloat()
    public var ageofDGPSData = CGFloat()
    public var DGPSid = Int()
    public var extensions: GPXExtensions?
    public var latitude = CGFloat()
    public var longitude = CGFloat()
    
    override init() {
        self.extensions = GPXExtensions()
        super.init()
    }
    
    override init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        self.extensions = GPXExtensions(XMLElement: element, parent: parent)
        
        super.init(XMLElement: element, parent: parent)
        
        self.elevationValue = text(forSingleChildElement: "ele", xmlElement: element)
        self.timeValue = text(forSingleChildElement: "time", xmlElement: element)
        self.magneticVariationValue = text(forSingleChildElement: "magvar", xmlElement: element)
        self.geoidHeightValue = text(forSingleChildElement: "geoidheight", xmlElement: element)
        self.name = text(forSingleChildElement: "name", xmlElement: element)
        self.comment = text(forSingleChildElement: "cmt", xmlElement: element)
        self.desc = text(forSingleChildElement: "desc", xmlElement: element)
        self.source = text(forSingleChildElement: "src", xmlElement: element)
        self.childElement(ofClass: GPXLink.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.links.add(element!)
            } })
        self.symbol = text(forSingleChildElement: "sym", xmlElement: element)
        self.type = text(forSingleChildElement: "type", xmlElement: element)
        self.fixValue = text(forSingleChildElement: "fix", xmlElement: element)
        self.satellitesValue = text(forSingleChildElement: "sat", xmlElement: element)
        self.horizontalDilutionValue = text(forSingleChildElement: "hdop", xmlElement: element)
        self.verticalDilutionValue = text(forSingleChildElement: "vdop", xmlElement: element)
        self.positionDilutionValue = text(forSingleChildElement: "pdop", xmlElement: element)
        self.ageOfDGPSDataValue = text(forSingleChildElement: "ageofdgpsdata", xmlElement: element)
        self.DGPSidValue = text(forSingleChildElement: "dgpsid", xmlElement: element)
        self.extensions = childElement(ofClass: GPXExtensions.self, xmlElement: element) as? GPXExtensions
        
        self.latitudeValue = value(ofAttribute: "lat", xmlElement: element, required: true)!
        self.longitudeValue = value(ofAttribute: "lon", xmlElement: element, required: true)!
        
        self.latitude = GPXType().latitude(latitudeValue)
        self.longitude =  GPXType().longitude(longitudeValue)
        
    }
    
    open func waypoint(With latitude: CGFloat, longitude: CGFloat) -> GPXWaypoint {
        let waypoint = GPXWaypoint()
        waypoint.latitude = latitude
        waypoint.longitude = longitude
        return waypoint
    }
    
    // MARK:- Public Methods
    
    public var elevation: CGFloat {
        return GPXType().decimal(elevationValue)
    }
    
    func set(Elevation elevation: CGFloat) {
        elevationValue = GPXType().value(forDecimal: elevation)
    }
    
    public var time: Date? {
        return GPXType().dateTime(value: timeValue)
    }
    
    func set(Time time: Date) {
        timeValue = GPXType().value(forDateTime: time)
    }
    
    public var magneticVariation: CGFloat {
        return GPXType().degrees(magneticVariationValue)
    }
    
    func set(MagneticVariation magneticVariation: CGFloat) {
        magneticVariationValue = GPXType().value(forDegrees: magneticVariation)
    }
    
    public var geoidHeight: CGFloat {
        return GPXType().decimal(geoidHeightValue)
    }
    
    func set(GeoidHeight geoidHeight: CGFloat) {
        geoidHeightValue = GPXType().value(forDecimal: geoidHeight)
    }
    
    open func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
    open func add(Link link: GPXLink?) {
        if link != nil {
            let index = links.index(of: link!)
            if index == NSNotFound {
                link?.parent = self
                links.add(link!)
            }
        }
    }
    
    open func add(Links array: NSArray) {
        for case let link as GPXLink in array {
            add(Link: link)
        }
    }
    
    open func remove(Link link: GPXLink) {
        let index = links.index(of: link)
        
        if index != NSNotFound {
            link.parent = nil
            links.remove(link)
        }
    }
    
    public var fix: Int { // maybe GPXFix would be better?
        return GPXType().fix(value: fixValue).rawValue
    }
    
    func set(Fix: Int) {
        fixValue = GPXType().value(forFix: GPXFix(rawValue: Fix) ?? .none)
    }
    
    public var satellites: Int {
        return GPXType().nonNegativeInt(satellitesValue)
    }
    
    func set(Satellites: Int) {
        satellitesValue = GPXType().value(forNonNegativeInt: Satellites)
    }
    
    public var horizontalDilution: CGFloat {
        return GPXType().decimal(horizontalDilutionValue)
    }
    
    func set(HorizontalDilution: CGFloat) {
        horizontalDilutionValue = GPXType().value(forDecimal: HorizontalDilution)
    }
    
    public var verticalDilution: CGFloat {
        return GPXType().decimal(horizontalDilutionValue)
    }
    
    func set(VerticalDilution: CGFloat) {
        verticalDilutionValue = GPXType().value(forDecimal: VerticalDilution)
    }
    
    public var positionDilution: CGFloat {
        return GPXType().decimal(positionDilutionValue)
    }
    
    func set(PositionDilution: CGFloat) {
        positionDilutionValue = GPXType().value(forDecimal: PositionDilution)
    }
    
    public var ageOfDGPSData: CGFloat {
        return GPXType().decimal(ageOfDGPSDataValue)
    }
    
    func set(DGPSid: Int) {
        DGPSidValue = GPXType().value(forDgpsStation: DGPSid)
    }
    
    func set(Latitude: CGFloat) {
        latitudeValue = GPXType().value(forLatitude: Latitude)
    }
    
    func set(Longitude: CGFloat) {
        longitudeValue = GPXType().value(forLongitude: Longitude)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "wpt"
    }
    
    // MARK:- GPX
    
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
        
        self.addProperty(forValue: elevationValue as NSString, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: timeValue as NSString, gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
        self.addProperty(forValue: magneticVariationValue as NSString, gpx: gpx, tagName: "magvar", indentationLevel: indentationLevel)
        self.addProperty(forValue: geoidHeightValue as NSString, gpx: gpx, tagName: "geoidheight", indentationLevel: indentationLevel)
        self.addProperty(forValue: name as NSString, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc as NSString, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source as NSString, gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        
        for case let link as GPXLink in self.links {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: symbol as NSString, gpx: gpx, tagName: "sym", indentationLevel: indentationLevel)
        self.addProperty(forValue: type as NSString, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        self.addProperty(forValue: fixValue as NSString, gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        self.addProperty(forValue: satellitesValue as NSString, gpx: gpx, tagName: "sat", indentationLevel: indentationLevel)
        self.addProperty(forValue: horizontalDilutionValue as NSString, gpx: gpx, tagName: "hdop", indentationLevel: indentationLevel)
        self.addProperty(forValue: verticalDilutionValue as NSString, gpx: gpx, tagName: "vdop", indentationLevel: indentationLevel)
        self.addProperty(forValue: positionDilutionValue as NSString, gpx: gpx, tagName: "pdop", indentationLevel: indentationLevel)
        self.addProperty(forValue: ageOfDGPSDataValue as NSString, gpx: gpx, tagName: "ageofdgpsdata", indentationLevel: indentationLevel)
        self.addProperty(forValue: DGPSidValue as NSString, gpx: gpx, tagName: "dgpsid", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}
