//
//  GPXLegacyWaypoint.swift
//  All codes for more straightforward GPX 1.0 and below, data handling.
//
//  Created by Vincent Neo on 6/6/20.
//  Components consolidated on 18/6/20.
//

import Foundation

// MARK:- Version

public enum GPXVersion: String {
    case pre4 = "0.4"
    case pre5 = "0.5"
    case pre6 = "0.6"
    case v1   = "1.0"
    //case v1_1 = "1.1"
    
    func getSchemaSite() -> String {
        switch self {
            case .pre4: return "http://www.topografix.com/GPX/0/4"
            case .pre5: return "http://www.topografix.com/GPX/0/5"
            case .pre6: return "http://www.topografix.com/GPX/0/6"
            case   .v1: return "http://www.topografix.com/GPX/1/0"
            
        }
    }
}

// MARK:- Root Element

public protocol GPXRootElement: GPXElement {
    var version: GPXVersion { get set }
    var creator: String { get set }
}

public final class GPXLegacyRoot: GPXElement, GPXRootElement {
    public var version: GPXVersion
    public var creator: String
    
    public var name: String?
    public var desc: String?
    public var author: String?
    public var email: String? // verifies if got @ in it.
    public var url: URL?
    public var urlName: String?
    public var time: Date?
    public var keywords: String?
    public var bounds: GPXBounds?
    public var waypoints = [GPXLegacyWaypoint]()
    public var routes = [GPXLegacyRoute]()
    public var tracks = [GPXLegacyTrack]()
    
    // MARK: GPX v1.0 Namespaces
    
    /// Link to the GPX v1.0 schema
    private var schema: String {
        get { return version.getSchemaSite() }
    }
    /// Link to the schema locations. If extended, the extended schema should be added.
    private var schemaLocation: String {
        get {
            return "\(version.getSchemaSite()) \(version.getSchemaSite())/gpx.xsd"
        }
    }
    /// Link to XML schema instance
    private let xsi = "http://www.w3.org/2001/XMLSchema-instance"
    
    public required init() {
        self.creator = "Powered by Open Source CoreGPX Project"
        self.version = .v1
        super.init()
    }
    
    init(raw: GPXRawElement) {
        self.creator = ""
        self.version = .v1
        
        for (key, value) in raw.attributes {
            switch key {
            case "creator":             self.creator = value
            case "version":             self.version = GPXVersion(rawValue: value) ?? .v1
            //case "xsi:schemaLocation":  self.schemaLocation = value
            //case "xmlns:xsi":           continue
            //case "xmlns":               continue
            default: continue
            }
        }
        
       for child in raw.children {
            switch child.name {
            case "name":     self.name = child.text
            case "desc":     self.desc = child.text
            case "author":   self.author = child.text
            case "email":    self.email = child.text
            case "url":      if let text = child.text { self.url = URL(string: text) }
            case "urlname":  self.urlName = child.text
            case "time":     self.time = GPXDateParser.parse(date: child.text)
            case "keywords": self.keywords = child.text
            case "bounds":   self.bounds = GPXBounds(raw: child)
            case "wpt":      self.waypoints.append(GPXLegacyWaypoint(raw: child))
            case "rte":      self.routes.append(GPXLegacyRoute(raw: child))
            case "trk":      self.tracks.append(GPXLegacyTrack(raw: child))
                // more needed
            default: continue
            }
        }
    }
    
    public init(creator: String, version: GPXVersion = .v1) {
        self.version = version
        self.creator = creator
        super.init()
    }
    
    public func addEmail(_ email: String) {
        let schemaPattern = #"[\p{L}_]+(\.[\p{L}_]+)*@[\p{L}_]+(\.[\p{L}_]+)+"#
        
        if email.range(of: schemaPattern, options: .regularExpression) != nil {
            self.email = email
        }
    }
    
    /*
    public func addEmail(_ email: String) throws {
        let schemaPattern = #"[\p{L}_]+(\.[\p{L}_]+)*@[\p{L}_]+(\.[\p{L}_]+)+"#
        
        if email.range(of: schemaPattern, options: .regularExpression) != nil {
            self.email = email
        }
        else {
            throw GPXError.others.invalidEmail
        }
    }
    */
    
    public func upgrade() -> GPXRoot {
        let modern = GPXRoot(creator: creator)
        let meta = GPXMetadata()
        meta.name = name
        meta.desc = desc
        
        if author != nil || email != nil {
            let mAuthor = GPXAuthor(name: author)
            if let email = email, email.contains("@") { mAuthor.email = GPXEmail(withFullEmailAddress: email) }
            meta.author = mAuthor
        }
        
        if url != nil {
            let mLink = GPXLink(withURL: url)
            mLink.text = urlName
            meta.links.append(mLink)
        }

        meta.time = time
        meta.keywords = keywords
        meta.bounds = bounds
        
        modern.metadata = meta
        
        /* REMINDER:
           ADD WPT, TRK, RTE types!! */
        for wpt in waypoints {
            modern.add(waypoint: wpt.upgrade())
        }
        
        for rte in routes {
            modern.add(route: rte.upgrade())
        }
        
        for trk in tracks {
            modern.add(track: trk.upgrade())
        }
        
        return modern
    }
    
    override func tagName() -> String {
        return "gpx"
    }
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        attribute.appendFormat(" xmlns:xsi=\"%@\"", self.xsi)
        attribute.appendFormat(" xmlns=\"%@\"", self.schema)
        attribute.appendFormat(" xsi:schemaLocation=\"%@\"", self.schemaLocation)
        
        attribute.appendFormat(" version=\"%@\"", version.rawValue)
        attribute.appendFormat(" creator=\"%@\"", creator)
        
        gpx.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n")
        
        gpx.appendOpenTag(indentation: indent(forIndentationLevel: indentationLevel), tag: tagName(), attribute: attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: author, gpx: gpx, tagName: "author", indentationLevel: indentationLevel)
        self.addProperty(forValue: email, gpx: gpx, tagName: "email", indentationLevel: indentationLevel)
        
        if let url = url {
            self.addProperty(forValue: url.absoluteString, gpx: gpx, tagName: "url", indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: urlName, gpx: gpx, tagName: "urlname", indentationLevel:  indentationLevel)
        self.addProperty(forValue: Convert.toString(from: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
        self.addProperty(forValue: keywords, gpx: gpx, tagName: "keywords", indentationLevel: indentationLevel)
        
        if let bounds = bounds {
            bounds.gpx(gpx, indentationLevel: indentationLevel)
        }
        for waypoint in waypoints {
            waypoint.gpx(gpx, indentationLevel: indentationLevel)
        }
        for track in tracks {
            track.gpx(gpx, indentationLevel: indentationLevel)
        }
        for route in routes {
            if version != .v1 { route.isVersion1 = false }
            route.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}






// MARK:- Waypoint

public class GPXLegacyWaypoint: GPXElement, GPXWaypointProtocol {
    public var elevation: Double?
    public var time: Date?
    public var magneticVariation: Double?
    public var geoidHeight: Double?
    public var name: String?
    public var comment: String?
    public var desc: String?
    public var source: String?
    public var symbol: String?
    public var type: String?
    public var fix: GPXFix?
    public var satellites: Int?
    public var horizontalDilution: Double?
    public var verticalDilution: Double?
    public var positionDilution: Double?
    public var ageofDGPSData: Double?
    public var DGPSid: Int?
    
    public var latitude: Double?
    public var longitude: Double?
    
    init(raw: GPXRawElement) {
        self.latitude = Convert.toDouble(from: raw.attributes["lat"])
        self.longitude = Convert.toDouble(from: raw.attributes["lon"])
        
        for child in raw.children {
            switch child.name {
            case "time":        self.time = GPXDateParser.parse(date: child.text)
            case "ele":         self.elevation = Convert.toDouble(from: child.text)
            case "magvar":      self.magneticVariation = Convert.toDouble(from: child.text)
            case "geoidheight": self.geoidHeight = Convert.toDouble(from: child.text)
            case "name":        self.name = child.text
            case "cmt":         self.comment = child.text
            case "desc":        self.desc = child.text
            case "src":         self.source = child.text
            case "url":         if let text = child.text { self.url = URL(string: text) }
            case "urlname":     self.urlName = child.text
            case "sym":         self.symbol = child.text
            case "type":        self.type = child.text
            case "fix":         self.fix = GPXFix(rawValue: child.text ?? "none")
            case "sat":         self.satellites = Convert.toInt(from: child.text)
            case "hdop":        self.horizontalDilution = Convert.toDouble(from: child.text)
            case "vdop":        self.verticalDilution = Convert.toDouble(from: child.text)
            case "pdop":        self.positionDilution = Convert.toDouble(from: child.text)
            case "dgpsid":      self.DGPSid = Convert.toInt(from: child.text)
            case "ageofdgpsid": self.ageofDGPSData = Convert.toDouble(from: child.text)
            //case "extensions":  self.extensions = GPXExtensions(raw: child)
            default: continue
            }
        }
    }
    
    public required init() {
    }
    
    /// URL of this particular waypoint, if any.
    public var url: URL?
    
    /// Name associated with the given URL.
    public var urlName: String?
    
    override func tagName() -> String {
        return "wpt"
    }
    
    func upgrade() -> GPXWaypoint {
        let upgraded: GPXWaypoint = self.convert()
        if let url = url, let urlName = urlName,
           let link = GPXLink(url: url, name: urlName) {
            upgraded.links.append(link)
        }
        return upgraded
    }
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        if let latitude = latitude {
            attribute.append(" lat=\"\(latitude)\"")
        }
        
        if let longitude = longitude {
            attribute.append(" lon=\"\(longitude)\"")
        }
        
        gpx.appendOpenTag(indentation: indent(forIndentationLevel: indentationLevel), tag: tagName(), attribute: attribute)
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: elevation, gpx: gpx, tagName: "ele", indentationLevel: indentationLevel)
        self.addProperty(forValue: Convert.toString(from: time), gpx: gpx, tagName: "time", indentationLevel: indentationLevel)
        addSpeedCourseTags(toGPX: gpx, indLvl: indentationLevel)
        self.addProperty(forDoubleValue: magneticVariation, gpx: gpx, tagName: "magvar", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: geoidHeight, gpx: gpx, tagName: "geoidheight", indentationLevel: indentationLevel)
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment, gpx: gpx, tagName: "cmt", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)

        if let url = url {
            self.addProperty(forValue: url.absoluteString, gpx: gpx, tagName: "url", indentationLevel: indentationLevel)
        }
        self.addProperty(forValue: urlName, gpx: gpx, tagName: "urlname", indentationLevel: indentationLevel)
        self.addProperty(forValue: symbol, gpx: gpx, tagName: "sym", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)

        if let fix = self.fix?.rawValue {
           self.addProperty(forValue: fix, gpx: gpx, tagName: "fix", indentationLevel: indentationLevel)
        }

        self.addProperty(forIntegerValue: satellites, gpx: gpx, tagName: "sat", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: horizontalDilution, gpx: gpx, tagName: "hdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: verticalDilution, gpx: gpx, tagName: "vdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: positionDilution, gpx: gpx, tagName: "pdop", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: ageofDGPSData, gpx: gpx, tagName: "ageofdgpsdata", indentationLevel: indentationLevel)
        self.addProperty(forIntegerValue: DGPSid, gpx: gpx, tagName: "dgpsid", indentationLevel: indentationLevel)
    }
    /// for overrides from `trkpt` only.
    internal func addSpeedCourseTags(toGPX gpx: NSMutableString, indLvl indentationLevel: Int) {}
}

// MARK:- Route

public class GPXLegacyRoute: GPXElement, GPXRouteType {
    
    public var name: String?
    
    /// Additional comment of the route.
    ///
    /// - Important:
    /// Not available in GPX 0.6 and below.
    public var comment: String?
    
    var isVersion1 = true
    
    public var desc: String?
    
    public var source: String?
    
    public var url: URL?
    
    public var urlName: String?
    
    public var number: Int?
    
    /// Stated in GPX 1.0 schema that it is only *proposed*
    //public var type: String?
    
    // MARK: TODO, ##other
    // according to schema, ##other, meant that additional tags can be added, kinda like extensions.
    
    public var points = [GPXLegacyRoutePoint]()
    
    init(raw: GPXRawElement) {
        for child in raw.children {
            switch child.name {
            case "name":        self.name = child.text
            case "cmt":         self.comment = child.text
            case "desc":        self.desc = child.text
            case "src":         self.source = child.text
            case "url":         if let text = child.text { self.url = URL(string: text) }
            case "urlname":     self.urlName = child.text
            case "number":      if let text = child.text { self.number = Int(text) }
            case "rtept":       self.points.append(GPXLegacyRoutePoint(raw: child))
            default: continue
            }
        }
    }
    
    public required init() {}
    
    override func tagName() -> String {
        return "rtept"
    }
    
    public func upgrade() -> GPXRoute {
        let rte = GPXRoute()
        rte.name = name
        rte.comment = comment
        rte.desc = desc
        rte.source = source
        if let link = GPXLink(url: url, name: urlName) {
            rte.links.append(link)
        }
        rte.number = number
        self.points.forEach { point in
            rte.add(routepoint: point.upgrade())
        }
        
        return rte
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        if isVersion1 {
            addProperty(forValue: comment, gpx: gpx, tagName: "cmt", indentationLevel: indentationLevel)
        }
        addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        addProperty(forValue: source, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        if let url = url {
            addProperty(forValue: url.absoluteString, gpx: gpx, tagName: "url", indentationLevel: indentationLevel)
        }
        if let name = urlName {
            addProperty(forValue: name, gpx: gpx, tagName: "urlname", indentationLevel: indentationLevel)
        }
        
        for point in points {
            point.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}


public final class GPXLegacyRoutePoint: GPXLegacyWaypoint {
    
    override func upgrade() -> GPXRoutePoint {
        let upgraded: GPXRoutePoint = self.convert()
        if let url = url, let urlName = urlName,
           let link = GPXLink(url: url, name: urlName) {
            upgraded.links.append(link)
        }
        return upgraded
    }
    
    override func tagName() -> String {
        return "rtept"
    }
}


// MARK:- Track

public final class GPXLegacyTrackPoint: GPXLegacyWaypoint {
    
    public var course: Double?
    public var speed: Double?
    
    override func upgrade() -> GPXTrackPoint {
        let upgraded: GPXTrackPoint = self.convert()
        if let url = url, let urlName = urlName,
           let link = GPXLink(url: url, name: urlName) {
            upgraded.links.append(link)
        }
        upgraded.extensions = GPXExtensions()
        var dict = [String : String]()
        if let course = course {
            dict["course"] = "\(course)"
        }
        if let speed = speed {
            dict["speed"] = "\(speed)"
        }
        upgraded.extensions!.append(at: "legacy", contents: dict)
        return upgraded
    }
    
    override func tagName() -> String {
        return "trkpt"
    }
    
    override func addSpeedCourseTags(toGPX gpx: NSMutableString, indLvl indentationLevel: Int) {
        self.addProperty(forDoubleValue: course, gpx: gpx, tagName: "course", indentationLevel: indentationLevel)
        self.addProperty(forDoubleValue: speed, gpx: gpx, tagName: "speed", indentationLevel: indentationLevel)
    }
    
}

public class GPXLegacyTrack: GPXElement {
    
    override func tagName() -> String {
        return "trk"
    }
    
    
    public var name: String?
    
    /// Additional comment of the route.
    ///
    /// - Important:
    /// Not available in GPX 0.6 and below.
    public var comment: String?
    
    var isVersion1 = true
    
    public var desc: String?
    
    public var source: String?
    
    public var url: URL?
    
    public var urlName: String?
    
    public var number: Int?
    
    /// Stated in GPX 1.0 schema that it is only *proposed*
    //public var type: String?
    
    // MARK: TODO, ##other
    // according to schema, ##other, meant that additional tags can be added, kinda like extensions.
   
    public var segments = [GPXLegacyTrackSegment]()
    
    init(raw: GPXRawElement) {
        for child in raw.children {
            switch child.name {
            case "name":        self.name = child.text
            case "cmt":         self.comment = child.text
            case "desc":        self.desc = child.text
            case "src":         self.source = child.text
            case "url":         if let text = child.text { self.url = URL(string: text) }
            case "urlname":     self.urlName = child.text
            case "number":      if let text = child.text { self.number = Int(text) }
            case "trkseg":      self.segments.append(GPXLegacyTrackSegment(raw: child))
            default: continue
            }
        }
    }
    
    public required init() {}
    
    public func upgrade() -> GPXTrack {
        let trk = GPXTrack()
        trk.name = name
        trk.comment = comment
        trk.desc = desc
        trk.source = source
        if let link = GPXLink(url: url, name: urlName) {
            trk.links.append(link)
        }
        trk.number = number
        self.segments.forEach { segment in
            trk.add(trackSegment: segment.upgrade())
        }
        
        return trk
    }
    
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        if isVersion1 {
            addProperty(forValue: comment, gpx: gpx, tagName: "cmt", indentationLevel: indentationLevel)
        }
        addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        addProperty(forValue: source, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        if let url = url {
            addProperty(forValue: url.absoluteString, gpx: gpx, tagName: "url", indentationLevel: indentationLevel)
        }
        if let name = urlName {
            addProperty(forValue: name, gpx: gpx, tagName: "urlname", indentationLevel: indentationLevel)
        }
        
        for segment in segments {
            segment.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
}

public class GPXLegacyTrackSegment: GPXElement {
    override func tagName() -> String {
        return "trkseg"
    }
    
    public var points = [GPXLegacyTrackPoint]()
    
    init(raw: GPXRawElement) {
        for child in raw.children {
            switch child.name {
            case "trkpt":      self.points.append(GPXLegacyTrackPoint(raw: child))
            default: continue
            }
        }
    }
    
    public func upgrade() -> GPXTrackSegment {
        let segment = GPXTrackSegment()
        self.points.forEach { point in
            segment.add(trackpoint: point.upgrade())
        }
        return segment
    }
    
    public required init() {}
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        for pt in points {
            pt.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
