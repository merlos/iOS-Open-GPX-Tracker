//
//  GPXTileServer.swift
//  OpenGpxTracker
//
//  Created by merlos on 25/01/15.
//
// Shared file: this file is also included in the OpenGpxTracker-Watch Extension target.

import Foundation

///
/// Configuration for supported tile servers.
///
/// Maps displayed in the application are sets of small square images caled tiles. There are different servers that
/// provide these tiles.
///
/// A tile server is defined by an internal id (for instance .openStreetMap), a name string for displaying
/// on the interface and a URL template.
///
enum GPXTileServer: Int {
    
    /// Apple tile server
    case apple
    
    /// Open Street Map tile server
    case openStreetMap
    //case AnotherMap
    
    /// CartoDB tile server
    case cartoDB
    
    ///String that describes the selected tile server.
    var name: String {
        switch self {
        case .apple: return "Apple Mapkit (no offline cache)"
        case .openStreetMap: return "Open Street Map"
        case .cartoDB: return "Carto DB"
        //case .AnotherMap: return "My Map"
        }
    }
    
    /// URL template of current tile server (it is of the form http://{s}.map.tile.server/{z}/{x}/{y}.png
    var templateUrl: String {
        switch self {
        case .apple: return ""
        case .openStreetMap: return "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .cartoDB: return "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png"
            
        //case .AnotherMap: return "http://another.map.tile.server/{z}/{x}/{y}.png"
        }
    }
    /// Returns the number of tile servers currently defined
    static var count: Int { return GPXTileServer.cartoDB.rawValue + 1}
}
