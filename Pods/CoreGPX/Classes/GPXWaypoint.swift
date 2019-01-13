//
//  GPXWaypoint.swift
//  GPXKit
//
//  Created by Vincent on 19/11/18.
//

import UIKit

open class GPXWaypoint: GPXElement {
    
    public var links = [GPXLink]()
    public var elevation = CGFloat()
    public var time: Date
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
     
    public init(latitude: CGFloat, longitude: CGFloat) {
        self.time = Date()
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
    
    // MARK:- Internal Methods
    
    func set(date: String) {
        if date.isEmpty == false {
            self.time = GPXType().dateTime(value: date) ?? Date()
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
