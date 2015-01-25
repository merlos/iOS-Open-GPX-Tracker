//
//  GPXTileServer.swift
//  OpenGpxTracker
//
//  Created by merlos on 25/01/15.
//  Copyright (c) 2015 TransitBox. All rights reserved.
//

import Foundation

enum GPXTileServer {
    case Apple
    case OpenStreetMaps
    case MapBox
    case OpenCycleMap
    //case AnotherMap
    
    var name: String {
        switch self {
        case .Apple: return "Apple Mapkit"
        case .OpenStreetMaps: return "Open Street Maps"
        case .MapBox: return "MapBox"
        case .OpenCycleMap: return "Open Cycle Maps"
        //case .AnotherMap: return "My Map"
        }
    }
    var templateUrl: String {
        switch self {
        case .Apple: return ""
        case .OpenStreetMaps: return "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .MapBox: return "http://otile3.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg"
        case .OpenCycleMap: return "http://b.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
        //case .AnotherMap: return "http://another.map.tile.server/{z}/{x}/{y}.png"
        }
    }
}
