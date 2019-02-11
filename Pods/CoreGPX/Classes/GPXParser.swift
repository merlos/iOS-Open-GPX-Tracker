//
//  GPXParser.swift
//  GPXKit
//
//  Created by Vincent on 2/11/18.
//  

import Foundation

open class GPXParser: NSObject, XMLParserDelegate {
    
    var parser: XMLParser
    
    // MARK:- Initializers
    
    public init(withData data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
        self.parser.parse()
    }
    
    public init(withPath path: String) {
        self.parser = XMLParser()
        super.init()
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            self.parser = XMLParser(data: data)
            self.parser.delegate = self
            self.parser.parse()
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
            self.parser.delegate = self
            self.parser.parse()
        }
        catch {
            print(error)
        }
    }
    
    // MARK:- GPX Parsing
    
    var element = String()
    
    // Arrays of elements
    var waypoints = [GPXWaypoint]()
    
    var routes = [GPXRoute]()
    var routepoints = [GPXRoutePoint]()
    
    var tracks = [GPXTrack]()
    var tracksegements = [GPXTrackSegment]()
    var trackpoints = [GPXTrackPoint]()
    
    // Dictionary of element

    var waypointDict = [String : String]()
    var trackpointDict = [String : String]()
    var routepointDict = [String : String]()
    var metadataDict = [String : String]()
    var extensionsDict = [String : String]()
    
    var linkDict = [String:String]()
    

    var metadata: GPXMetadata?
    var extensions: GPXExtensions?
    
    // GPX v1.1 XML Schema tag types
    var isWaypoint = false
    var isMetadata = false
    var isRoute = false
    var isRoutePoint = false
    var isTrack = false
    var isTrackSegment = false
    var isTrackPoint = false
    var isExtensions = false
  
    var isLink = false
    var elementHasLink = false

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

            isExtensions = true
        case "link":
            isLink = true
            linkDict["href"] = attributeDict["href"]
        default:
            break
        }

    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let foundString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if foundString.isEmpty == false {
            if element != "trkpt" || element != "wpt" || element != "rtept" || element != "metadata" || element != "extensions" {

                if isWaypoint {
                    if isLink {
                        linkDict[element] = foundString
                    }
                    else {
                        waypointDict[element] = foundString
                    }
                }
                if isTrackPoint {
                    if isLink {
                        linkDict[element] = foundString
                    }
                    else {
                        trackpointDict[element] = foundString
                    }
                }
                if isRoutePoint {
                    if isLink {
                        linkDict[element] = foundString
                    }
                    else {
                        routepointDict[element] = foundString
                    }
                }
                if isMetadata {
                    if isLink {
                        linkDict[element] = foundString
                    }
                    else {
                        metadataDict[element] = foundString
                    }
                }
                if isExtensions {
                    extensionsDict[element] = foundString
                 }
            }
            
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "metadata":
            self.metadata = GPXMetadata(dictionary: metadataDict)
            if elementHasLink {
                self.metadata?.link = GPXLink(dictionary: linkDict)
                linkDict.removeAll()
                elementHasLink = false
            }
          
            // clear values
            isMetadata = false
            metadataDict.removeAll()
            
        case "trkpt":
            let tempTrackPoint = GPXTrackPoint(dictionary: trackpointDict)
            if elementHasLink {
                tempTrackPoint.link = GPXLink(dictionary: linkDict)
                linkDict.removeAll()
                elementHasLink = false
            }
            self.trackpoints.append(tempTrackPoint)
            
            // clear values
            isTrackPoint = false
            trackpointDict.removeAll()
            
        case "wpt":
            let tempWaypoint = GPXWaypoint(dictionary: waypointDict)
            if elementHasLink {
                tempWaypoint.link = GPXLink(dictionary: linkDict)
                linkDict.removeAll()
                elementHasLink = false
            }
            self.waypoints.append(tempWaypoint)
            
            // clear values
            isWaypoint = false
            waypointDict.removeAll()
            
        case "rte":
            let tempRoute = GPXRoute()
            tempRoute.add(routepoints: self.routepoints)
            self.routes.append(tempRoute)
            
            // clear values
            isRoute = false
            self.routepoints.removeAll()
            
        case "rtept":
            let tempRoutePoint = GPXRoutePoint(dictionary: routepointDict)
            if elementHasLink {
                tempRoutePoint.link = GPXLink(dictionary: linkDict)
                linkDict.removeAll()
                elementHasLink = false
            }
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
            self.extensions = GPXExtensions()
          
            // clear values
            isExtensions = false
            
        case "link":
            elementHasLink = true
            
            //clear values
            isLink = false
            
        default:
            break
        }
    }
    
    // MARK:- Export parsed data
    
    open func parsedData() -> GPXRoot {
        let root = GPXRoot()
        root.metadata = metadata
        root.extensions = extensions // nothing to implement yet
        root.add(waypoints: waypoints)
        root.add(routes: routes)
        root.add(tracks: tracks)
        return root
    }
}
