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
struct ZoomableTile {
    
    /// Path for the tile with `maximumZ` supported by the tile server set in the config.
    /// This is the path with the best resolution tile from wich this zoomable tile can be interpolated.
    /// - SeeAlso: `MapCacheConfig``
    let maximumZPath: MKTileOverlayPath
    
    /// Rectangle area ocupied by this tile
    let rect: MKMapRect
    
    /// Delta from given tile z to desired tile z.
    /// Example: maximum zoom supported by the server is 20 and the desired tile is in zoom level 24, the delta is 4.
    let overZoom: Zoom
}

