//
//  GPXRoute.swift
//  GPXKit
//
//  Created by Vincent on 8/12/18.
//  WORK IN PROGRESS

import Foundation

open class GPXRoute: GPXElement {
    
    public var name: String?
    public var comment: String?
    public var desc: String?
    public var source: String?
    public var link: GPXLink?
    public var type: String?
    public var extensions: GPXExtensions?
    public var routepoints = [GPXRoutePoint]()
    public var number: Int?
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    init(dictionary: [String : String]) {
        super.init()
        self.name = dictionary["name"]
        self.comment = dictionary["cmt"]
        self.desc = dictionary["desc"]
        self.source = dictionary["src"]
        self.type = dictionary["type"]
        self.number = integer(from: dictionary["number"])
    }
    
    private func integer(from string: String?) -> Int? {
        guard let NonNilString = string else {
            return nil
        }
        return Int(NonNilString)
    }
    
    // MARK: Public Methods
    
    func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink(withHref: href)
        return link
    }
    
    /*
    func add(link: GPXLink?) {
        if let validLink = link {
            link?.parent = self
            links.append(validLink)
        }
    }
    
    func add(links: [GPXLink]) {
        self.links.append(contentsOf: links)
    }
    
    func remove(link: GPXLink) {
        let contains = links.contains(link)
        
        if contains == true {
            link.parent = nil
            
            if let index = links.firstIndex(of: link) {
                links.remove(at: index)
            }
        }
    }
    */

    func newRoutePointWith(latitude: Double, longitude: Double) -> GPXRoutePoint {
        let routepoint = GPXRoutePoint(latitude: latitude, longitude: longitude)

        self.add(routepoint: routepoint)
        
        return routepoint
    }
    
    func add(routepoint: GPXRoutePoint?) {
        if let validPoint = routepoint {
            routepoints.append(validPoint)
        }
    }
    
    func add(routepoints: [GPXRoutePoint]) {
        self.routepoints.append(contentsOf: routepoints)
    }
    
    func remove(routepoint: GPXRoutePoint) {
        let contains = routepoints.contains(routepoint)
        if contains == true {
            routepoint.parent = nil
            if let index = routepoints.firstIndex(of: routepoint) {
                routepoints.remove(at: index)
            }
        }
        
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "rte"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment, gpx: gpx, tagName: "comment", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        if let link = link {
           link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forIntegerValue: number, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for routepoint in routepoints {
            routepoint.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
