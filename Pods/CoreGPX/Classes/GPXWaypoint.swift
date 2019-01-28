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
    public var time: Date?
    public var magneticVariation: CGFloat?
    public var geoidHeight: CGFloat?
    public var name: String?
    public var comment: String?
    public var desc: String?
    public var source: String?
    public var symbol: String?
    public var type: String?
    public var fix: Int?
    public var satellites: Int?
    public var horizontalDilution: CGFloat?
    public var verticalDilution: CGFloat?
    public var positionDilution: CGFloat?
    public var ageofDGPSData: CGFloat?
    public var DGPSid: Int?
    public var extensions: GPXExtensions? = GPXExtensions()
    public var latitude: CGFloat?
    public var longitude: CGFloat?
    
    public var latitudeString = String()
    public var longitudeString = String()
    public var elevationString = String()
    public var timeString = String()
    public var magneticVariationString = String()
    public var geoidHeightString = String()
    public var fixString = String()
    public var satellitesString = String()
    public var hdopString = String()
    public var vdopString = String()
    public var pdopString = String()
    public var ageofDGPSDataString = String()
    public var DGPSidString = String()
    
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
    
    public init(dictionary: [String:String]) {
        self.time = ISO8601DateParser.parse(dictionary ["time"] ?? "")
        super.init()
        self.elevation = number(from: dictionary["ele"])
        self.latitude = number(from: dictionary["lat"])
        self.longitude = number(from: dictionary["lon"])
        self.magneticVariation = number(from: dictionary["magvar"])
        self.geoidHeight = number(from: dictionary["geoidheight"])
        self.name = dictionary["name"]
        self.comment = dictionary["cmt"]
        self.desc = dictionary["desc"]
        self.source = dictionary["src"]
        self.symbol = dictionary["sym"]
        self.type = dictionary["type"]
        self.fix = Int(dictionary["fix"] ?? "")
        self.satellites = Int(dictionary["sat"] ?? "")
        self.horizontalDilution = number(from: dictionary["hdop"])
        self.verticalDilution = number(from: dictionary["vdop"])
        self.positionDilution = number(from: dictionary["pdop"])
        self.DGPSid = Int(dictionary["dgpsid"] ?? "")
    }
    
    // MARK:- Public Methods
   
    func number(from string: String?) -> CGFloat {
        return CGFloat(Double(string ?? "") ?? 0)
    }
    
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
        self.addProperty(forValue: GPXType().value(forDateTime: time!) as NSString, gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: magneticVariation, gpx: gpx, tagName: "magvar", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: geoidHeight, gpx: gpx, tagName: "geoidheight", indentationLevel: indentationLevel)
        self.addProperty(forValue: name as NSString?, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc as NSString?, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source as NSString?, gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        
        for link in links {
            link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: symbol as NSString?, gpx: gpx, tagName: "sym", indentationLevel: indentationLevel)
        self.addProperty(forValue: type as NSString?, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: CGFloat(fix ?? 0), gpx: gpx, tagName: "source", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: CGFloat(satellites ?? 0), gpx: gpx, tagName: "sat", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: horizontalDilution, gpx: gpx, tagName: "hdop", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: verticalDilution, gpx: gpx, tagName: "vdop", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: positionDilution, gpx: gpx, tagName: "pdop", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: ageofDGPSData, gpx: gpx, tagName: "ageofdgpsdata", indentationLevel: indentationLevel)
        self.addProperty(forNumberValue: CGFloat(DGPSid ?? 0), gpx: gpx, tagName: "dgpsid", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}

// code from http://jordansmith.io/performant-date-parsing/
// edited for use in CoreGPX

class ISO8601DateParser {
    
    private static var calendarCache = [Int : Calendar]()
    private static var components = DateComponents()
    
    private static let year = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let month = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let day = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let hour = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let minute = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let second = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    
    static func parse(_ dateString: String) -> Date? {
        if dateString != "" {
            _ = withVaList([year, month, day, hour, minute,
                            second], { pointer in
                                vsscanf(dateString, "%d-%d-%dT%d:%d:%dZ", pointer)
                                
            })
            
            components.year = year.pointee
            components.minute = minute.pointee
            components.day = day.pointee
            components.hour = hour.pointee
            components.month = month.pointee
            components.second = second.pointee
            
            if let calendar = calendarCache[0] {
                return calendar.date(from: components)
            }
            
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(secondsFromGMT: 0)!
            calendarCache[0] = calendar
            return calendar.date(from: components)
        }
        else {
            return nil
        }
    }
    
}

