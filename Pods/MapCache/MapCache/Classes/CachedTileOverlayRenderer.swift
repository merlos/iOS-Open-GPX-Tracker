//
//  CachedTileZoomRenderer.swift
//  MapCache
//
//  Created by Cameron Deardorff on 9/20/20.
//
//

import Foundation
import MapKit

///
/// A Tile overlay that supports to zoom beyond the maximumZ
///
/// Tile servers allow from 1 to a certain zoom level typically between 16 and 21 (set in `MapCacheConfig.maximumZ`).
/// Beyond that zoom levels tiles are not available in the server
///
/// This renderer takes the maximumZ tile and extracts the portion that would correspond to the requested level.
///
class CachedTileOverlayRenderer: MKTileOverlayRenderer {
    
    /// Indicates if the renderer is ready to draw. It´s always true
    /// - SeeAlso: [MKOverlayRenderer](https://developer.apple.com/documentation/mapkit/mkoverlayrenderer)
    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        // very important to call super.canDraw first, some sort of side effect happening which allows this to work (???).
        let _ = super.canDraw(mapRect, zoomScale: zoomScale)
        return true
    }
    
    /// Draws the tile in the map
    /// - Parameters:
    ///     - mapRect: the map rect where the tiles need to be drawn
    ///     - zoomScale: current zoom in the map
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        
        // use default rendering if the type of overlay is not CachedTileOverlay
        guard let cachedOverlay = overlay as? CachedTileOverlay else {
            super.draw(mapRect, zoomScale: zoomScale, in: context)
            return
        }
        
        // use default rendering when tiles are available
        guard cachedOverlay.shouldZoom(at: zoomScale) else {
            super.draw(mapRect, zoomScale: zoomScale, in: context)
            return
        }
        
        //Extract the zoomable tiles for this mapRect
        let tiles = cachedOverlay.tilesInMapRect(rect: mapRect, scale: zoomScale)
        
        for tile in tiles {
            cachedOverlay.loadTile(at: tile.maximumZPath) { [weak self] (data, error) in
                guard let strongSelf = self,
                      let data = data,
                      let provider = CGDataProvider(data: data as CFData),
                      let image = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
                        ?? CGImage(pngDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: CGColorRenderingIntent.defaultIntent)
                else { return }
                
                let tileScaleFactor = CGFloat(tile.overZoom) / zoomScale
                let cgRect = strongSelf.rect(for: tile.rect)
                let drawRect = CGRect(x: 0, y: 0, width: CGFloat(image.width), height: CGFloat(image.height))
                context.saveGState()
                context.translateBy(x: cgRect.minX, y: cgRect.minY)
                context.scaleBy(x: tileScaleFactor, y: tileScaleFactor)
                context.translateBy(x: 0, y: CGFloat(image.height))
                context.scaleBy(x: 1, y: -1)
                context.draw(image, in: drawRect)
                context.restoreGState()
            }
        }
    }
}
