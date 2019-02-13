//
//  GPXBounds.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import Foundation

open class GPXBounds: GPXElement {

    public var minLatitude: Double?
    public var maxLatitude: Double?
    public var minLongitude: Double?
    public var maxLongitude: Double?
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    public init(minLatitude: Double, maxLatitude: Double, minLongitude: Double, maxLongitude: Double) {
        super.init()
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    init(dictionary: [String : String]) {
        super.init()
        self.minLatitude = number(from: dictionary["minlat"])
        self.maxLatitude = number(from: dictionary["maxlat"])
        self.minLongitude = number(from: dictionary["minlon"])
        self.maxLongitude = number(from: dictionary["maxlon"])
    }
    
    func number(from string: String?) -> Double? {
        guard let NonNilString = string else {
            return nil
        }
        return Double(NonNilString)
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "bounds"
    }
    
    // MARK:- GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        if let minLatitude = minLatitude {
            attribute.appendFormat(" minlat=\"%f\"", minLatitude)
        }
        if let minLongitude = minLongitude {
            attribute.appendFormat(" minlon=\"%f\"", minLongitude)
        }
        if let maxLatitude = maxLatitude {
            attribute.appendFormat(" maxlat=\"%f\"", maxLatitude)
        }
        if let maxLongitude = maxLongitude {
            attribute.appendFormat(" maxlon=\"%f\"", maxLongitude)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", indent(forIndentationLevel: indentationLevel))
    }
}
