//
//  GPXParser.swift
//  GPXKit
//
//  Created by Vincent on 2/11/18.
//  

import Foundation

open class GPXParser: NSObject, XMLParserDelegate {
    
    private var parser: XMLParser
    
    // MARK:- Initializers
    
    public init(withData data: Data) {
        self.parser = XMLParser(data: data)
        super.init()
        self.parser.delegate = self
        self.parser.parse()
    }
    /*
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
    */
    
    public init?(withURL url: URL) {
        guard let urlParser = XMLParser(contentsOf: url) else { return nil }
        self.parser = urlParser
        super.init()
        self.parser.delegate = self
        self.parser.parse()
    }
    
    convenience init?(withPath path: String) {
        guard let url = URL(string: path) else { return nil }
        self.init(withURL: url)
    }
    
    public init(withStream stream: InputStream) {
        self.parser = XMLParser(stream: stream)
        super.init()
        self.parser.delegate = self
        self.parser.parse()
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
    var trackDict = [String : String]()
    var trackpointDict = [String : String]()
    var routeDict = [String : String]()
    var routepointDict = [String : String]()
    
    var linkDict = [String : String]()
    var extensionsDict = [String : String]()
    
    // metadata types
    var metadataDict = [String : String]()
    var boundsDict = [String : String]()
    var authorDict = [String : String]()
    var emailDict = [String : String]()
    var copyrightDict = [String : String]()
    

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
    
    // for metadata
    var isBounds = false
    var elementHasBounds = false
    var isAuthor = false
    var elementHasAuthor = false
    var isEmail = false
    var elementHasEmail = false
    var isCopyright = false
    var elementHasCopyright = false

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
        
        // for metadata
        case "bounds":
            isBounds = true
            boundsDict["minlon"] = attributeDict["minlon"]
            boundsDict["maxlon"] = attributeDict["maxlon"]
            boundsDict["minlat"] = attributeDict["minlat"]
            boundsDict["maxlat"] = attributeDict["maxlat"]
        case "author":
            isAuthor = true
        case "email":
            isEmail = true
        case "copyright":
            isCopyright = true
            copyrightDict["author"] = attributeDict["author"]
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
                if isTrack {
                    if isLink {
                        linkDict[element] = foundString
                    }
                    trackDict[element] = foundString
                }
                if isTrackPoint {
                    if isLink {
                        linkDict[element] = foundString
                    }
                    else {
                        trackpointDict[element] = foundString
                    }
                }
                if isRoute {
                    if isLink {
                        linkDict[element] = foundString
                    }
                    routeDict[element] = foundString
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
                    if isLink && !isAuthor {
                        linkDict[element] = foundString
                    }
                    if isBounds {
                        // do nothing
                    }
                    if isAuthor {
                        if isLink {
                            linkDict[element] = foundString
                        }
                        else {
                            if isEmail {
                                emailDict[element] = foundString
                            }
                            authorDict[element] = foundString
                        }
                    }
                    if isCopyright {
                        copyrightDict[element] = foundString
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
            if elementHasLink && !elementHasAuthor {
                self.metadata?.link = GPXLink(dictionary: linkDict)
                
                // clear values
                linkDict.removeAll()
                elementHasLink = false
            }
            if elementHasBounds {
                self.metadata?.bounds = GPXBounds(dictionary: boundsDict)
                
                // clear values
                boundsDict.removeAll()
                elementHasBounds = false
            }
            if elementHasAuthor {
                let author = GPXAuthor(dictionary: authorDict)
                if elementHasLink {
                    author.link = GPXLink(dictionary: linkDict)
                    
                    // clear values
                    linkDict.removeAll()
                    elementHasLink = false
                }
                if elementHasEmail {
                    author.email = GPXEmail(dictionary: emailDict)
                    
                    // clear values
                    emailDict.removeAll()
                    elementHasEmail = false
                }
                self.metadata?.author = author
                
                // clear values
                authorDict.removeAll()
                elementHasAuthor = false
            }
            if elementHasCopyright {
                self.metadata?.copyright = GPXCopyright(dictionary: copyrightDict)
                
                // clear values
                copyrightDict.removeAll()
                elementHasCopyright = false
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
            let tempRoute = GPXRoute(dictionary: routeDict)
            tempRoute.add(routepoints: self.routepoints)
            if elementHasLink {
                tempRoute.link = GPXLink(dictionary: linkDict)
                linkDict.removeAll()
                elementHasLink = false
            }
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
            self.routepointDict.removeAll()
            
        case "trk":
            let tempTrack = GPXTrack(dictionary: trackDict)
            tempTrack.add(trackSegments: self.tracksegements)
            if elementHasLink {
                tempTrack.link = GPXLink(dictionary: linkDict)
                linkDict.removeAll()
                elementHasLink = false
            }
            self.tracks.append(tempTrack)
            
            //clear values
            isTrack = false
            self.trackDict.removeAll()
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
            
            // clear values
            isLink = false
            
        case "bounds":
            elementHasBounds = true
            
            // clear values
            isBounds = false
            
        case "author":
            elementHasAuthor = true
            
            // clear values
            isAuthor = false
            
        case "email":
            elementHasEmail = true
            
            // clear values
            isEmail = false
            
        case "copyright":
            elementHasCopyright = true
            
            // clear values
            isCopyright = false
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
