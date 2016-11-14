//
//  GPXTileServer.swift
//  OpenGpxTracker
//
//  Created by merlos on 25/01/15.
//  Copyright (c) 2015 TransitBox. All rights reserved.
//

import Foundation

enum GPXTileServer: Int {
    case apple
    case openStreetMap
    case openCycleMap
    //case AnotherMap
    case cartoDB
    
    
    var name: String {
        switch self {
        case .apple: return "Apple Mapkit (no offline cache)"
        case .openStreetMap: return "Open Street Map"
        case .openCycleMap: return "Open Cycle Maps"
        case .cartoDB: return "Carto DB"
        //case .AnotherMap: return "My Map"
        }
    }

    var templateUrl: String {
        switch self {
        case .apple: return ""
        case .openStreetMap: return "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .openCycleMap: return "http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png"
        case .cartoDB: return "http://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
            
        //case .AnotherMap: return "http://another.map.tile.server/{z}/{x}/{y}.png"
        }
    }
    static var count: Int { return GPXTileServer.cartoDB.hashValue + 1}
}
