//
//  MKZoomScale+MapCache.swift
//  MapCache
//
//  Created by merlos on 26/09/2020.
//

import Foundation
import MapKit

/// Extension for MapCache
extension MKZoomScale {
    ///
    /// Converts from standard MapKit MKZoomScale to tile zoom level
    /// - Parameter tileSize: current map tile size in pixels. Typically set in MapCacheConfig
    /// - Returns: Corresponding zoom level for a tile
    func toZoomLevel(tileSize: CGSize) -> Int {
        let numTilesAt1_0 = MKMapSize.world.width / Double(tileSize.width)
        let zoomLevelAt1_0 = log2(numTilesAt1_0)
        let zoomLevel: Double = Double.maximum(0, zoomLevelAt1_0 + Double(floor(log2(self) + 0.5)))
        return Int(zoomLevel)
    }
}
