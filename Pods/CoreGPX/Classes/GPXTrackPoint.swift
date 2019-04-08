//
//  GPXTrackPoint.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import Foundation

/**
 A track point is just like a waypoint or route point, but is suited to be part of a track segment.
 
 A bunch of track points can be used to form a track segement, while track segments form a track.
 (though a single track segment itself is enough to form a track.)
 */
open class GPXTrackPoint: GPXWaypoint {
    
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
        super.init(coder: aDecoder)
        guard let time = aDecoder.decodeObject(forKey: "time") as? Date,
            let elevation = aDecoder.decodeObject(forKey: "elevation") as? Double,
            let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double,
            let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double
            else {
                return nil
        }
        
        self.time = time
        self.elevation = elevation
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public override func encode(with aCoder: NSCoder) {
        aCoder.encode(self.time, forKey: "time")
        aCoder.encode(self.elevation, forKey: "elevation")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
    }
    
    // MARK:- Tag
    
    override func tagName() -> String {
        return "trkpt"
    }
    
}

enum PointKey: String, CodingKey {
    case time //= "time"
    case elevation// = "ele"
    case latitude// = "lat"
    case longitude //= "lon"
    case magneticVariation// = "magvar"
    case geoidHeight// = "geoidheight"
    case name //= "name"
    case comment// = "cmt"
    case desc// = "desc"
    case source //= "src"
    case type// = "sym"
    case fix //= "fix"
    case satellites// = "sat"
    case horizontalDilution// = "hdop"
    case verticalDilution// = "vdop"
    case positionDilution// = "pdop"
    case DGPSid //= "dgpsid"
    case ageOfDGPSData //= "ageofdgpsdata"
}

