//
//  CachedTileOverlay.swift
//
//  Base source code comes from Open GPX Tracker http://github.com/iOS-Open-GPX-Tracker
//
//

import Foundation
import MapKit


///
/// Whenever a tile is requested by the `MapView`, it calls the `MKTileOverlay.loadTile`.
/// This class overrides the default `MKTileOverlay`to provide support to `MapCache`.
///
/// - SeeAlso: `MkMapView+MapCache`
///
public class CachedTileOverlay : MKTileOverlay {
    
    /// A class that implements the `MapCacheProtocol`
    let mapCache : MapCacheProtocol
    
    /// If true `loadTile` uses the implementation of  the `mapCache` var. If `false`, uses the
    /// default `MKTileOverlay`implementation from Apple.
    public var useCache: Bool = true
    
    /// Constructor.
    /// - Parameter withCache: the cache to be used on `loadTile`
    public init(withCache cache: MapCacheProtocol) {
        mapCache = cache
        super.init(urlTemplate: mapCache.config.urlTemplate)
    }
    
    ///
    /// Generates the URL for the tile to be requested.
    /// It replaces the values of {z},{x} and {y} in the `urlTemplate`defined in `mapCache.config`
    ///
    /// - SeeAlso: `MapCache`, `MapCacheConfig`
    ///
    override public func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        return mapCache.url(forTilePath: path)
    }
    
    ///
    /// When invoked it will load the tile using the standard OS implementation (if `useCache`is `false`)
    /// or from the cache (if `useCache` is `true`
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
    
    ///
    /// Tells whether or not to upsample and show a lesser detailed z level
    /// takes into account `useZoom` configuration as well as current and `maximumZ` values
    /// - Parameter at current zoom.
    func shouldZoom(at scale: MKZoomScale) -> Bool {
        guard mapCache.config.overZoomMaximumZ else { return false }
        return scale.toZoomLevel(tileSize: mapCache.config.tileSize) > mapCache.config.maximumZ
    }
    
    ///
    /// Given the maximum zoom level for the tileset `(mapCache.config.maximumZ`) it will return the tile, map rects, and additional scaling factor for upscaling tiles.
    ///
    /// - Parameter rect: map rectangle for which we want to get the tile set
    /// - Parameter scale: current zoom scale
    ///
    func tilesInMapRect(rect: MKMapRect, scale: MKZoomScale) -> [ZoomableTile] {
        var tiles: [ZoomableTile] = []
        let tileSize = mapCache.config.tileSize
        var z = scale.toZoomLevel(tileSize: tileSize)
       
        // Represents the number of tiles the current tile is going to be divided
        var overZoom = 1
        let tileSetMaxZ = mapCache.config.maximumZ
        if (z > tileSetMaxZ) {
            overZoom = Int(pow(2.0, Double(z - tileSetMaxZ)))
            z = tileSetMaxZ
        }
        
        let adjustedTileSize = Double(overZoom * Int(tileSize.width))
        
        let minX = Int(floor((rect.minX * Double(scale)) / adjustedTileSize))
        let maxX = Int(floor((rect.maxX * Double(scale)) / adjustedTileSize))
        let minY = Int(floor((rect.minY * Double(scale)) / adjustedTileSize))
        let maxY = Int(floor((rect.maxY * Double(scale)) / adjustedTileSize))
        
        for x in minX ... maxX {
            for y in minY ... maxY {
                
                let point = MKMapPoint(x: (Double(x) * adjustedTileSize) / Double(scale),
                                       y: (Double(y) * adjustedTileSize) / Double(scale))
                let size = MKMapSize(width: adjustedTileSize / Double(scale),
                                     height: adjustedTileSize / Double(scale))
                let tileRect = MKMapRect(origin: point, size: size)
                
                // check that a portion of the tile intersects with the maps rect
                // no need to do the work on a tile that won't be seen
                guard rect.intersects(tileRect) else { continue }
                
                let path =  MKTileOverlayPath(x: x, y: y, z: z, contentScaleFactor: scale)
                let tile = ZoomableTile(maximumZPath: path, rect: tileRect, overZoom: Zoom(overZoom))
                tiles.append(tile)
            }
        }
        return tiles
    }
}
