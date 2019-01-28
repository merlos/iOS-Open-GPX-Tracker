//
//  GPXTrackPoint.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

open class GPXTrackPoint: GPXWaypoint {
    
    public required init() {
        super.init()
    }
    
    // MARK:- Instance
    
    public override init(latitude: CGFloat, longitude: CGFloat) {
        super.init()
    }
    
    public override init(dictionary: [String : String]) {
        super.init()
        self.time = ISO8601DateParser.parse(dictionary ["time"] ?? "")
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
        self.fix = Int(dictionary["fix"] ?? "")
        self.satellites = Int(dictionary["sat"] ?? "")
        self.horizontalDilution = number(from: dictionary["hdop"])
        self.verticalDilution = number(from: dictionary["vdop"])
        self.positionDilution = number(from: dictionary["pdop"])
        self.DGPSid = Int(dictionary["dgpsid"] ?? "")
    }
    /*
 public var links = [GPXLink]()
 public var elevation = CGFloat()
 public var time: Date?
 public var magneticVariation = CGFloat()
 public var geoidHeight = CGFloat()
 public var name: String?
 public var comment = String()
 public var desc: String?
 public var source = String()
 public var symbol = String()
 public var type = String()
 public var fix = Int()
 public var satellites = Int()
 public var horizontalDilution = CGFloat()
 public var verticalDilution = CGFloat()
 public var positionDilution = CGFloat()
 public var ageofDGPSData = CGFloat()
 public var DGPSid = Int()
 public var extensions: GPXExtensions? = GPXExtensions()
 public var latitude: CGFloat?
 public var longitude: CGFloat?
 */
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "trkpt"
    }

}
