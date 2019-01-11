//
//  GPXParser.swift
//  GPXKit
//
//  Created by Vincent on 2/11/18.
//  

import UIKit

open class GPXParser: NSObject, XMLParserDelegate {
    
    var parser: XMLParser
    
    // MARK:- Init
    
    public init(withData data: Data) {
        
        self.parser = XMLParser(data: data)
        super.init()
        parser.delegate = self
        parser.parse()
    }
    
    public init(withPath path: String) {
        self.parser = XMLParser()
        super.init()
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            self.parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        catch {
            print(error)
        }
    }
    
    public init(withURL url: URL) {
        self.parser = XMLParser()
        super.init()
        do {
            let data = try Data(contentsOf: url)
            self.parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        catch {
            print(error)
        }
    }
    
    // MARK:- GPX Parsing
    
    var element = String()
    var latitude: CGFloat? = CGFloat()
    var longitude: CGFloat? = CGFloat()
    
    // Elements
    var waypoint = GPXWaypoint()
    var route = GPXRoute()
    var routepoint = GPXRoutePoint()
    var track = GPXTrack()
    var tracksegment = GPXTrackSegment()
    var trackpoint = GPXTrackPoint()
    
    // Arrays of elements
    var waypoints = [GPXWaypoint]()
    var routes = [GPXRoute]()
    var routepoints = [GPXRoutePoint]()
    
    var tracks = [GPXTrack]()
    var tracksegements = [GPXTrackSegment]()
    var trackpoints = [GPXTrackPoint]()
    
    var metadata: GPXMetadata? = GPXMetadata()
    var extensions: GPXExtensions? = GPXExtensions()
    
    var isWaypoint: Bool = false
    var isMetadata: Bool = false
    var isRoute: Bool = false
    var isRoutePoint: Bool = false
    var isTrack: Bool = false
    var isTrackSegment: Bool = false
    var isTrackPoint: Bool = false
    var isExtension: Bool = false
    
    func value(from string: String?) -> CGFloat? {
        if string != nil {
            if let number = NumberFormatter().number(from: string!) {
                return CGFloat(number.doubleValue)
            }
        }
        return nil
    }

    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        element = elementName
        
        switch elementName {
        case "metadata":
            isMetadata = true
        case "wpt":
            isWaypoint = true
            latitude = value(from: attributeDict ["lat"])
            longitude = value(from: attributeDict ["lon"])
        case "rte":
            isRoute = true
        case "rtept":
            isRoutePoint = true
        case "trk":
            isTrack = true
        case "trkseg":
            isTrackSegment = true
        case "trkpt":
            isTrackPoint = true
            latitude = value(from: attributeDict ["lat"])
            longitude = value(from: attributeDict ["lon"])
        case "extensions":
            isExtension = true
        default: ()
        }

    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let foundString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isWaypoint || isTrackPoint || isRoutePoint {
            waypoint.latitude = latitude
            waypoint.longitude = longitude
            if foundString.isEmpty == false {
                switch element {
                case "ele":
                    self.waypoint.elevation = value(from: foundString)!
                case "time":
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
                    self.waypoint.time = dateFormatter.date(from: foundString)!
                case "magvar":
                    self.waypoint.magneticVariation = value(from: foundString)!
                case "geoidheight":
                    self.waypoint.geoidHeight = value(from: foundString)!
                case "name":
                    self.waypoint.name = foundString
                case "desc":
                    self.waypoint.desc = foundString
                case "source":
                    self.waypoint.source = foundString
                case "sat":
                    self.waypoint.satellites = Int(value(from: foundString)!)
                case "hdop":
                    self.waypoint.horizontalDilution = value(from: foundString)!
                case "vdop":
                    self.waypoint.verticalDilution = value(from: foundString)!
                case "pdop":
                    self.waypoint.positionDilution = value(from: foundString)!
                case "ageofdgpsdata":
                    self.waypoint.ageofDGPSData = value(from: foundString)!
                case "dgpsid":
                    self.waypoint.DGPSid = Int(value(from: foundString)!)
                default: ()
                }
            }
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
            
        case "metadata":
            isMetadata = false
            
        case "wpt":
            let tempWaypoint = GPXWaypoint()
            
            // copy values
            tempWaypoint.elevation = self.waypoint.elevation
            tempWaypoint.time = self.waypoint.time
            tempWaypoint.magneticVariation = self.waypoint.magneticVariation
            tempWaypoint.geoidHeight = self.waypoint.geoidHeight
            tempWaypoint.name = self.waypoint.name
            tempWaypoint.desc = self.waypoint.desc
            tempWaypoint.source = self.waypoint.source
            tempWaypoint.satellites = self.waypoint.satellites
            tempWaypoint.horizontalDilution = self.waypoint.horizontalDilution
            tempWaypoint.verticalDilution = self.waypoint.verticalDilution
            tempWaypoint.positionDilution = self.waypoint.positionDilution
            tempWaypoint.ageofDGPSData = self.waypoint.ageofDGPSData
            tempWaypoint.DGPSid = self.waypoint.DGPSid
            tempWaypoint.latitude = self.waypoint.latitude
            tempWaypoint.longitude = self.waypoint.longitude
            
            self.waypoints.append(tempWaypoint)
            // clear values
            isWaypoint = false
            latitude = nil
            longitude = nil
            
        case "rte":
            self.route.add(routepoints: routepoints)
            let tempTrack = GPXRoute()
            tempTrack.routepoints = self.route.routepoints
            self.routes.append(route)
            
            // clear values
            isRoute = false
            
        case "rtept":
            
            let tempRoutePoint = GPXRoutePoint()
            
            // copy values
            tempRoutePoint.elevation = self.waypoint.elevation
            tempRoutePoint.time = self.waypoint.time
            tempRoutePoint.magneticVariation = self.waypoint.magneticVariation
            tempRoutePoint.geoidHeight = self.waypoint.geoidHeight
            tempRoutePoint.name = self.waypoint.name
            tempRoutePoint.desc = self.waypoint.desc
            tempRoutePoint.source = self.waypoint.source
            tempRoutePoint.satellites = self.waypoint.satellites
            tempRoutePoint.horizontalDilution = self.waypoint.horizontalDilution
            tempRoutePoint.verticalDilution = self.waypoint.verticalDilution
            tempRoutePoint.positionDilution = self.waypoint.positionDilution
            tempRoutePoint.ageofDGPSData = self.waypoint.ageofDGPSData
            tempRoutePoint.DGPSid = self.waypoint.DGPSid
            tempRoutePoint.latitude = self.waypoint.latitude
            tempRoutePoint.longitude = self.waypoint.longitude
            
            self.routepoints.append(tempRoutePoint)
            
            isRoutePoint = false
        case "trk":
            
            self.track.add(trackSegments: tracksegements)
            
            let tempTrack = GPXTrack()
            tempTrack.tracksegments = self.track.tracksegments
            self.tracks.append(tempTrack)
            
            //clear values
            isTrack = false
            
        case "trkseg":
            self.tracksegment.add(trackpoints: trackpoints)
            
            let tempTrackSegment = GPXTrackSegment()
            tempTrackSegment.trackpoints = self.tracksegment.trackpoints
            self.tracksegements.append(tempTrackSegment)
            
            // clear values
            isTrackSegment = false
            
        case "trkpt":
            
            let tempTrackPoint = GPXTrackPoint()
            
            // copy values
            tempTrackPoint.elevation = self.waypoint.elevation
            tempTrackPoint.time = self.waypoint.time
            tempTrackPoint.magneticVariation = self.waypoint.magneticVariation
            tempTrackPoint.geoidHeight = self.waypoint.geoidHeight
            tempTrackPoint.name = self.waypoint.name
            tempTrackPoint.desc = self.waypoint.desc
            tempTrackPoint.source = self.waypoint.source
            tempTrackPoint.satellites = self.waypoint.satellites
            tempTrackPoint.horizontalDilution = self.waypoint.horizontalDilution
            tempTrackPoint.verticalDilution = self.waypoint.verticalDilution
            tempTrackPoint.positionDilution = self.waypoint.positionDilution
            tempTrackPoint.ageofDGPSData = self.waypoint.ageofDGPSData
            tempTrackPoint.DGPSid = self.waypoint.DGPSid
            tempTrackPoint.latitude = self.waypoint.latitude
            tempTrackPoint.longitude = self.waypoint.longitude
            
            self.trackpoints.append(tempTrackPoint)
            
            // clear values
            isTrackPoint = false
            latitude = nil
            longitude = nil
        case "extensions":
            isExtension = false
        default: ()
        }
    }
    
    // MARK:- Export parsed data
    
    open func parsedData() -> GPXRoot {
        let root = GPXRoot()
        root.add(waypoints: waypoints)
        root.add(routes: routes)
        root.add(tracks: tracks)
        return root
    }

}
