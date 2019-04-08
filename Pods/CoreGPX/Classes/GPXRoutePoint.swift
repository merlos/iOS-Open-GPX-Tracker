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
    
    override init(dictionary: [String : String]) {
        super.init()
        self.time = ISO8601DateParser.parse(dictionary ["time"])
        self.elevation = Convert.toDouble(from: dictionary["ele"])
        self.latitude = Convert.toDouble(from: dictionary["lat"])
        self.longitude = Convert.toDouble(from: dictionary["lon"])
        self.magneticVariation = Convert.toDouble(from: dictionary["magvar"])
        self.geoidHeight = Convert.toDouble(from: dictionary["geoidheight"])
        self.name = dictionary["name"]
        self.comment = dictionary["cmt"]
        self.desc = dictionary["desc"]
        self.source = dictionary["src"]
        self.symbol = dictionary["sym"]
        self.type = dictionary["type"]
        self.fix = Convert.toInt(from: dictionary["fix"])
        self.satellites = Convert.toInt(from: dictionary["sat"])
        self.horizontalDilution = Convert.toDouble(from: dictionary["hdop"])
        self.verticalDilution = Convert.toDouble(from: dictionary["vdop"])
        self.positionDilution = Convert.toDouble(from: dictionary["pdop"])
        self.DGPSid = Convert.toInt(from: dictionary["dgpsid"])
        self.ageofDGPSData = Convert.toDouble(from: dictionary["ageofdgpsdata"])
    }
    
    /*
    required public init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: PointKey.self)
        time = try ISO8601DateParser.parse(container.decode(String.self, forKey: .time))
        elevation = try container.decode(Double.self, forKey: .elevation)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        //fatalError("init(from:) has not been implemented")
    }
    */
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "rtept"
    }
}
