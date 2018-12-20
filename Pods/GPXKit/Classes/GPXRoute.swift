//
//  GPXRoute.swift
//  GPXKit
//
//  Created by Vincent on 8/12/18.
//  WORK IN PROGRESS

import UIKit

open class GPXRoute: GPXElement {
    
    var name = String()
    var comment = String()
    var desc = String()
    var source = String()
    var links = NSMutableArray()
    var type = String()
    var extensions: GPXExtensions?
    var routepoints = NSMutableArray()
    var numberValue = String()
    
    // MARK:- Instance
    
    override init() {
        //links = NSMutableArray()
        //routepoints = NSMutableArray()
        super.init()
    }
    
    override init(XMLElement element: UnsafeMutablePointer<TBXMLElement>?, parent: GPXElement?) {
        
        super.init(XMLElement: element, parent: parent)
        
        name = text(forSingleChildElement: "name", xmlElement: element)
        comment = text(forSingleChildElement: "cmt", xmlElement: element)
        desc = text(forSingleChildElement: "desc", xmlElement: element)
        source = text(forSingleChildElement: "src", xmlElement: element)
        
        self.childElement(ofClass: GPXLink.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.links.add(element!)
            } })
        
        numberValue = text(forSingleChildElement: "number", xmlElement: element)
        
        type = text(forSingleChildElement: "type", xmlElement: element)
        
        extensions = childElement(ofClass: GPXExtensions.self, xmlElement: element) as? GPXExtensions
        
        self.childElement(ofClass: GPXRoutePoint.self, xmlElement: element, eachBlock: { element in
            if element != nil {
                self.routepoints.add(element!)
            } })
        
    }
    
    // MARK: Public Methods
    
    var number: Int {
        return GPXType().nonNegativeInt(numberValue)
    }
    
    func set(number: Int) {
        numberValue = GPXType().value(forNonNegativeInt: number)
    }
    
    func newLink(withHref href: String) -> GPXLink {
        let link: GPXLink = GPXLink().link(with: href)
        return link
    }
    
    func add(link: GPXLink?) {
        if link != nil {
            let index = links.index(of: link!)
            if index == NSNotFound {
                link?.parent = self
                links.add(link!)
            }
        }
    }
    
    func add(links: [GPXLink]) {
        for link in links {
            add(link: link)
        }
    }
    
    func remove(Link link: GPXLink) {
        let index = links.index(of: link)
        
        if index != NSNotFound {
            link.parent = nil
            links.remove(link)
        }
    }
    
    func newRoutePointWith(latitude: CGFloat, longitude: CGFloat) -> GPXRoutePoint {
        let routepoint = GPXRoutePoint().routePoint(with: latitude, longitude: longitude)
        self.add(routepoint: routepoint)
        
        return routepoint
    }
    
    func add(routepoint: GPXRoutePoint?) {
        if routepoint != nil {
            let index: Int = routepoints.index(of: routepoint!)
            
            if index == NSNotFound {
                routepoint?.parent = nil
                routepoints.remove(routepoint!)
            }
        }
    }
    
    func add(routepoints: [GPXRoutePoint]) {
        for routepoint in routepoints {
            add(routepoint: routepoint)
        }
    }
    
    func remove(routepoint: GPXRoute) {
        let index = routepoints.index(of: routepoint)
        
        if index != NSNotFound {
            routepoint.parent = nil
            routepoints.remove(routepoint)
        }
        
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "rte"
    }
    
    // MARK:- GPX
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        
        self.addProperty(forValue: name as NSString, gpx: gpx, tagName: "name", indentationLevel: indentationLevel)
        self.addProperty(forValue: comment as NSString, gpx: gpx, tagName: "comment", indentationLevel: indentationLevel)
        self.addProperty(forValue: desc as NSString, gpx: gpx, tagName: "desc", indentationLevel: indentationLevel)
        self.addProperty(forValue: source as NSString, gpx: gpx, tagName: "src", indentationLevel: indentationLevel)
        
        for case let link as GPXLink in self.links {
           link.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        self.addProperty(forValue: numberValue as NSString, gpx: gpx, tagName: "number", indentationLevel: indentationLevel)
        self.addProperty(forValue: type as NSString, gpx: gpx, tagName: "type", indentationLevel: indentationLevel)
        
        if self.extensions != nil {
            self.extensions?.gpx(gpx, indentationLevel: indentationLevel)
        }
        
        for case let routepoint as GPXRoutePoint in self.routepoints {
            routepoint.gpx(gpx, indentationLevel: indentationLevel)
        }
        
    }
    
}
