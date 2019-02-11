//
//  GPXRoute.swift
//  GPXKit
//
//  Created by Vincent on 8/12/18.
//  WORK IN PROGRESS

import Foundation

open class GPXRoute: GPXElement {
    
    var name = String()
    var comment = String()
    var desc = String()
    var source = String()
    var links = [GPXLink]()
    var type = String()
    var extensions: GPXExtensions?
    var routepoints = [GPXRoutePoint]()
    var numberValue = String()
    var number = Int()
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    // MARK: Public Methods
    
    func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
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
        
        for link in links {
           link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: GPXType().value(forNonNegativeInt: number), gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for routepoint in routepoints {
            routepoint.gpx(gpx, indentationLevel: indentationLevel)
        }
    }
}
