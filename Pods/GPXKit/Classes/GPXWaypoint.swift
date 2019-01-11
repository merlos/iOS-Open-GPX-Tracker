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
    public var links = [GPXLink]()
    var fixValue = String()
    var satellitesValue = String()
    var horizontalDilutionValue = String()
    var verticalDilutionValue = String()
    var positionDilutionValue = String()
    var ageOfDGPSDataValue = String()
    var DGPSidValue = String()
    var latitudeValue:String?
    var longitudeValue:String?
    
    public var elevation = CGFloat()
    public var time = Date()
    public var magneticVariation = CGFloat()
    public var geoidHeight = CGFloat()
    public var name: String?
    public var comment = String()
    public var desc: String?
    public var source = String()
    public var symbol = String()
    public var type = String()
    public var fix = Int()
    public var satellites = Int()
    public var horizontalDilution = CGFloat()
    public var verticalDilution = CGFloat()
    public var positionDilution = CGFloat()
    public var ageofDGPSData = CGFloat()
    public var DGPSid = Int()
    public var extensions: GPXExtensions? = GPXExtensions()
    public var latitude: CGFloat?
    public var longitude: CGFloat?
    
    public required init() {
        self.time = Date()
        super.init()
    }
    
    public required init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        
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
                self.links.append(element! as! GPXLink)
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
        self.elevation = GPXType().decimal(elevationValue)
        //self.time = GPXType().dateTime(value: timeValue)
        self.magneticVariation = GPXType().degrees(magneticVariationValue)
        self.geoidHeight = GPXType().decimal(geoidHeightValue)
        self.fix = GPXType().fix(value: fixValue).rawValue
        self.satellites = GPXType().nonNegativeInt(satellitesValue)
        self.horizontalDilution = GPXType().decimal(horizontalDilutionValue)
        self.verticalDilution = GPXType().decimal(verticalDilutionValue)
        self.positionDilution = GPXType().decimal(positionDilutionValue)
        self.ageofDGPSData = GPXType().decimal(ageOfDGPSDataValue)
    }
    
    public init(latitude: CGFloat, longitude: CGFloat) {
        super.init()
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // MARK:- Public Methods
    
    open func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
    open func add(link: GPXLink?) {
        if link != nil {
            let contains = links.contains(link!)
            if contains == false {
                link?.parent = self
                links.append(link!)
            }
        }
    }
    
    open func add(links: [GPXLink]) {
        for link in links {
            add(link: link)
        }
    }
    
    open func remove(Link link: GPXLink) {
        let contains = links.contains(link)
        
        if contains == true {
            link.parent = nil
            if let index = links.firstIndex(of: link) {
                links.remove(at: index)
            }
        }
    }

    // MARK:- Tag
    
    override func tagName() -> String! {
        return "wpt"
    }
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute: NSMutableString = ""
        
        if latitude != nil {
            attribute.appendFormat(" lat=\"%f\"", latitude!)
        }
        
        if longitude != nil {
            attribute.appendFormat(" lon=\"%f\"", longitude!)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel), self.tagName(), attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forNumberValue: elevation, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: GPXType().value(forDateTime: time) as NSString, gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: magneticVariation, gpx: gpx, tagName: "magvar", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: geoidHeight, gpx: gpx, tagName: "geoidheight", indentationLevel: indentationLevel)
        self.addProperty(forValue: name as NSString?, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc as NSString?, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source as NSString, gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        
        for link in links {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: symbol as NSString, gpx: gpx, tagName: "sym", indentationLevel: indentationLevel)
        self.addProperty(forValue: type as NSString, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: CGFloat(fix), gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: CGFloat(satellites), gpx: gpx, tagName: "sat", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: horizontalDilution, gpx: gpx, tagName: "hdop", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: verticalDilution, gpx: gpx, tagName: "vdop", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: positionDilution, gpx: gpx, tagName: "pdop", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: ageofDGPSData, gpx: gpx, tagName: "ageofdgpsdata", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: CGFloat(DGPSid), gpx: gpx, tagName: "dgpsid", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}
