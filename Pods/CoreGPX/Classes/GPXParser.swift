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
    
    // Dictionary of element
    var waypointDict = [String:String]()
    var trackpointDict = [String:String]()
    var routepointDict = [String:String]()
    
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
        case "wpt":
            isWaypoint = true
            waypointDict["lat"] = attributeDict["lat"]
            waypointDict["lon"] = attributeDict["lon"]
        case "trk":
            isTrack = true
        case "trkseg":
            isTrackSegment = true
        case "trkpt":
            isTrackPoint = true
            trackpointDict["lat"] = attributeDict["lat"]
            trackpointDict["lon"] = attributeDict["lon"]
        case "rte":
            isRoute = true
        case "rtept":
            isRoutePoint = true
            routepointDict["lat"] = attributeDict["lat"]
            routepointDict["lon"] = attributeDict["lon"]
        case "metadata":
            isMetadata = true
        case "extensions":
            isExtension = true
        default: ()
        }

    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let foundString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if foundString.isEmpty == false {
            if element != "trkpt" || element != "wpt" || element != "rtept" {
                if isWaypoint {
                    waypointDict[element] = foundString
                }
                if isTrackPoint {
                    trackpointDict[element] = foundString
                }
                if isRoutePoint {
                    routepointDict[element] = foundString
                }
            }
        }
        
        if isMetadata {
            if foundString.isEmpty != false {
                switch element {
                case "name":
                    self.metadata!.name = foundString
                case "desc":
                    self.metadata!.desc = foundString
                case "time":
                    self.metadata!.set(date: foundString)
                case "keyword":
                    self.metadata!.keyword = foundString
                // author, copyright, link, bounds, extensions not implemented.
                default: ()
                }
            }
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
            
        case "metadata":
            isMetadata = false
            
        case "trkpt":
            let tempTrackPoint = GPXTrackPoint(dictionary: trackpointDict)
            
            self.trackpoints.append(tempTrackPoint)
 
            // clear values
            isTrackPoint = false
            trackpointDict.removeAll()
            
        case "wpt":
            let tempWaypoint = GPXWaypoint(dictionary: waypointDict)
           
            self.waypoints.append(tempWaypoint)
            // clear values
            isWaypoint = false
            waypointDict.removeAll()
            
        case "rte":
            
            let tempTrack = GPXRoute()
            
            tempTrack.add(routepoints: self.routepoints)
            
            self.routes.append(route)
            
            // clear values
            isRoute = false
            self.routepoints.removeAll()
            
        case "rtept":
            
            let tempRoutePoint = GPXRoutePoint(dictionary: routepointDict)
            
            self.routepoints.append(tempRoutePoint)
            
            // clear values
            isRoutePoint = false
            routepointDict.removeAll()
            
        case "trk":
            
            let tempTrack = GPXTrack()
            
            tempTrack.add(trackSegments: self.tracksegements)
            
            self.tracks.append(tempTrack)
            
            //clear values
            isTrack = false
            self.tracksegements.removeAll()
            
        case "trkseg":
            
            
            let tempTrackSegment = GPXTrackSegment()
            
            tempTrackSegment.add(trackpoints: self.trackpoints)
            
            self.tracksegements.append(tempTrackSegment)
            
            // clear values
            isTrackSegment = false
            self.trackpoints.removeAll()

        case "extensions":
            isExtension = false
            
        default: ()
        }
    }
    
    // MARK:- Export parsed data
    
    open func parsedData() -> GPXRoot {
        let root = GPXRoot()
        root.metadata = metadata // partially implemented
        root.extensions = extensions // not implemented
        root.add(waypoints: waypoints)
        root.add(routes: routes)
        root.add(tracks: tracks)
        return root
    }

}
