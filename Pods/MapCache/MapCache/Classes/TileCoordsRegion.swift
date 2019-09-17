//
//  MapRegion.swift
//  MapCache
//
//  Created by merlos on 13/06/2019.
//

import Foundation



/// 3 dimensional square region in a tile map.
/// The three dimensions are:
///  - latitude (y)
///  - longitude (x)
///  - zoom (z)
///
/// A region is represented by two `TileCoords` one holds
/// the topLeft corner and the other the bottomRight corner.
///
/// Notice that, in general, map UIs represent an infinite scroll in the
/// longitude (x) axis, when the map ends, it is displayed the beginning.
///
/// In this scenario, if we allow user to pick two points to select a region,
/// we may end up with two sub-regions.
///
///     +---------------------++---------------------++---------------------+
///     |                     ||                     ||                     |
///     |             * P1    ||                     ||                     |
///     |                     ||                     ||                     |
///     |       Map 1         ||        Map 1bis     ||       Map 1 bis bis |
///     |                     ||                     ||                     |
///     |                     ||  * P2               ||                     |
///     |                     ||                     ||                     |
///     +---------------------++---------------------++---------------------+
///
///
public class TileCoordsRegion {

    // Top left tile/coordinate
    public var topLeft : TileCoords
    
    // Bottom right tile/coordinate
    public var bottomRight : TileCoords
    
    //Zoom range for the region
    public var zoomRange: ZoomRange {
        get {
            let z1 = topLeft.zoom
            let z2 = bottomRight.zoom
            if z1 >= z2 {
                return ZoomRange(z1, z2)!
            }
            return ZoomRange(z2, z1)!
        }
    }

    //Total number of tiles in this region for all zoom levels
    public var count : TileNumber {
        get {
            var counted: TileNumber = 0
            for zoom in zoomRange {
                counted += count(forZoom: zoom)
            }
            return counted
        }
    }
    
    /// The region will be the area that holds the line from any top left point (P1) to any
    /// bottom rightpoint 2 (P2)
    public init?(topLeftLatitude: Double, topLeftLongitude: Double, bottomRightLatitude: Double, bottomRightLongitude: Double, minZoom: UInt8, maxZoom: UInt8) {
        guard let _topLeft = TileCoords(latitude: topLeftLatitude, longitude: topLeftLongitude, zoom: minZoom) else { return nil }
        guard let _bottomRight = TileCoords(latitude: bottomRightLatitude, longitude: bottomRightLongitude, zoom: maxZoom) else { return nil}
        topLeft = _topLeft
        bottomRight = _bottomRight
    }
    
    /// The region will be the area that holds the line from any top left point (P1) to any
    /// bottom rightpoint 2 (P2)
    /// For example, in this map:
    ///
    ///     +---------------------++---------------------++---------------------+
    ///     |               P1    ||                     ||                     |
    ///     |                * . .||. +                  ||                     |
    ///     |                . \  ||  ·                  ||                     |
    ///     |       Map 1    .  \ ||  ·     Map 2        ||       Map 3         |
    ///     |                .   \||  ·                  ||                     |
    ///     |                .    \|  ·                  ||                     |
    ///     |                .    |\  ·                  ||                     |
    ///     |                .    ||\ ·                  ||                     |
    ///     |                .    || \·                  ||                     |
    ///     |                + . .||. * P2               ||                     |
    ///     +---------------------++---------------------++---------------------+
    ///    -180                180 -180                 180
    ///
    /// The area will be the one denoted with the dots.
    ///
    public init?(topLeft: TileCoords, bottomRight: TileCoords) {
        //Validate latitudes
        if (topLeft.latitude < bottomRight.latitude) {
            return nil
        }
        
        self.topLeft = topLeft
        self.bottomRight = bottomRight
    }
    
    //Counts for the zoom
    public func count(forZoom zoom: Zoom) -> TileNumber {
        guard let ranges = tileRanges(forZoom: zoom) else {
            return 0
        }
        var counted : TileNumber = 0
        for range in ranges {
            counted += range.count
        }
        return counted
    }
    
    // All the tile ranges for this particular zoom.
    // There may be 1 or 2.
    ///
    /// For example, in this map there are two ranges. One that covers the area A1
    /// and other that covers the area A2
    ///
    ///     +----------------------++---------------------++---------------------+
    ///     |               P1     ||                     ||                     |
    ///     |                *.....||...+                  ||                     |
    ///     |                . \  .||.  ·                  ||                     |
    ///     |       Map 1    .  \ .||.  ·     Map 2        ||       Map 3         |
    ///     |                .   \.||.  ·                  ||                     |
    ///     |                .    \||.A2·                  ||                     |
    ///     |                .  A1.|\.  ·                  ||                     |
    ///     |                .    .||\  ·                  ||                     |
    ///     |                .    .||.\ ·                  ||                     |
    ///     |                +.....||...* P2               ||                     |
    ///     +----------------------++---------------------++---------------------+
    ///    -180                180 -180                 180
    ///
    ///
    
    public func tileRanges(forZoom zoom: Zoom) -> [TileRange]? {
        //We create new tileCoords at the zoom
        guard let topLeftForZoom = TileCoords(topLeft,zoom: zoom) else {
            return nil
        }
        guard let bottomRightForZoom = TileCoords(bottomRight, zoom: zoom) else {
            return nil
        }
        
        if (topLeft.longitude <= bottomRight.longitude) {
            // Normal scenario.
            let range1 = TileRange(zoom: zoom,
                                   minTileX: topLeftForZoom.tileX,
                                   maxTileX: bottomRightForZoom.tileX,
                                   minTileY: topLeftForZoom.tileY,
                                   maxTileY: bottomRightForZoom.tileY)
            return [range1]
        }
        // If top left longitude is > bottomRight that means that
        // the map ended between topLeft and bottomRight.
        // so we will have two ranges.
        // - from topleft longitude to the end of the map
        // - from the beggining of the map to bottom right long
        let range1 = TileRange(zoom: zoom,
                               minTileX: topLeftForZoom.tileX,
                               maxTileX: TileCoords.maxTile(forZoom: zoom),
                               minTileY: topLeftForZoom.tileY,
                               maxTileY: bottomRightForZoom.tileY)
        let range2 = TileRange(zoom: zoom,
                               minTileX: 0,
                               maxTileX: bottomRightForZoom.tileX,
                               minTileY: topLeftForZoom.tileY,
                               maxTileY: bottomRightForZoom.tileY)
        return [range1, range2]
    }
    
    /// Gets the tile ranges for all zooms.
    public func tileRanges() -> [TileRange]? {
        var ranges : [TileRange] = []
        for zoom in zoomRange {
            ranges.append(contentsOf: tileRanges(forZoom: zoom) ?? [])
        }
        return ranges
    }
    
}
