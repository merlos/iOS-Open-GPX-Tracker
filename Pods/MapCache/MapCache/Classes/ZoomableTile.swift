//
//  ZoomableTile.swift
//  MapCache
//
//  Created by merlos on 26/09/2020.
//

import Foundation
import MapKit

///
/// Specifies a single tile and area of the tile that should upscaled.
///
public struct ZoomableTile {
    
    /// Path for the tile with `maximumZ` supported by the tile server set in the config.
    /// This is the path with the best resolution tile from wich this zoomable tile can be interpolated.
    /// - SeeAlso: `MapCacheConfig``
    let maximumZPath: MKTileOverlayPath
    
    /// Rectangle area ocupied by this tile
    let rect: MKMapRect
    
    /// Scale over the tile of the maximumZ path.
    /// It is a multiple of 2 (2, 4, 8).
    /// For a zoom larger than maximumZ represents the number of tiles the original tile is divided in
    /// one axis. For example,  overZoom=4 means that in each axis the tile is divided in 4 as well as
    /// in the Y axis. So, the original tile at maximumZ is divided in 16 subtiles.
    /// The `rect`tells us, among those tiles, which one is this tile.
    let overZoom: Int
}

