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
    case OpenStreetMap
    case MapQuest
    case OpenCycleMap
    case CartoDB
    //case AnotherMap
    
    var name: String {
        switch self {
        case .Apple: return "Apple Mapkit"
        case .OpenStreetMap: return "Open Street Map"
        case .MapQuest: return "MapQuest Open"
        case .OpenCycleMap: return "Open Cycle Maps"
        case .CartoDB: return "Carto DB"
        //case .AnotherMap: return "My Map"
        }
    }
    var templateUrl: String {
        switch self {
        case .Apple: return ""
        case .OpenStreetMap: return "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .MapQuest: return "http://otile3.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.jpg"
        case .OpenCycleMap: return "http://b.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
        case .CartoDB: return "http://b.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
        
        //case .AnotherMap: return "http://another.map.tile.server/{z}/{x}/{y}.png"
        }
    }
}
