//
//  CachedTileOverlay.swift
//
//  Base source code comes from Open GPX Tracker http://github.com/iOS-Open-GPX-Tracker
//
//

import Foundation
import MapKit


///
/// Overwrites the default overlay to store downloaded images
///
public class CachedTileOverlay : MKTileOverlay {
    
    let mapCache : MapCacheProtocol
    
    public var useCache: Bool = true
    
    public init(withCache cache: MapCacheProtocol) {
        mapCache = cache
        super.init(urlTemplate: mapCache.config.urlTemplate)
    }
    
    ///
    /// Generates the URL for the tile to be requested.
    /// It replaces the values of {z},{x} and {y} in the urlTemplate defined in GPXTileServer
    ///
    /// -SeeAlso: GPXTileServer
    ///
    override public func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        return mapCache.url(forTilePath: path)
    }
    
    ///
    /// Loads the tile from the network or from cache
    ///
    /// If the internal app cache is activated,it tries to get the tile from it.
    /// If not, it uses the default system cache (managed by the OS).
    ///
    override public func loadTile(at path: MKTileOverlayPath,
                           result: @escaping (Data?, Error?) -> Void) {
        if !self.useCache { // Use cache by use cache is not set.
           // print("loadTile:: not using cache")
            return super.loadTile(at: path, result: result)
        } else {
           return mapCache.loadTile(at: path, result: result)
        }
    }
}
