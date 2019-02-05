//
//  GPXRoutePoint.swift
//  GPXKit
//
//  Created by Vincent on 19/11/18.
//

import Foundation

open class GPXRoutePoint: GPXWaypoint {
    
    public required init() {
        super.init()
    }
    
    // MARK:- Instance
    
    public override init(latitude: Double, longitude: Double) {
        super.init()
        self.latitude = latitude
        self.longitude = longitude

    }
    
    public override init(dictionary: [String : String]) {
        super.init()
        self.time = ISO8601DateParser.parse(dictionary ["time"])
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
        self.fix = integer(from: dictionary["fix"])
        self.satellites = integer(from: dictionary["sat"])
        self.horizontalDilution = number(from: dictionary["hdop"])
        self.verticalDilution = number(from: dictionary["vdop"])
        self.positionDilution = number(from: dictionary["pdop"])
        self.DGPSid = integer(from: dictionary["dgpsid"])
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "rtept"
    }
}
