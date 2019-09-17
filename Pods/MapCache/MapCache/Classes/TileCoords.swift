//
//  TileCoords.swift
//  MapCache
//
//  Created by merlos on 10/06/2019.
//

import Foundation

/// An alias for UInt8. Used to indicate that the variable is holding a zoom value.
///
/// Notice that Zoom shoul have only values between 0 and 19.
/// - SeeAlso: TileCoords
public typealias Zoom = UInt8

/// Tile number in a map.
/// - SeeAlso TileCoords
public typealias TileNumber = UInt64

/// Errors for Zoom
enum ZoomError: Error {
    /// Zoom largest value is 19
    case largerThan19
}

/// Errors for a latitude
enum LatitudeError: Error {
    case overflowMin
    case overflowMax
}

/// Errors for a longitude
enum LongitudeError: Error {
    case overflowMin
    case overflowMax
}

/// Errors for a tile
enum TileError: Error {
    case overflow
}

///
/// Class to convert from Map Tiles to coordinates and from coordinates to tiles
///
/// Coordinates (latitude and longitude) are ALWAYS expressed in degrees.
/// The max latitude that can be converted to tiles is +85.0511 and the minimum
///  is -85.0511 (see https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames).
///
/// Zoom level (z) range is from 0 to 19.
///
/// The earth is represented by a square that is divided in small pieces (tiles).
/// The number of tiles depends on the zoom value and is equal to: 2^z x 2^z
///
/// The values of tiles can be from 0 to 2^z - 1. For instance, for z=10
/// the max tile would be 1023 (2^10 - 1 = 1024 - 1)
///
/// This diagram represents the equivalent lat/long vs tileX/tileY
///
///
///     (-180,85.0511)           (180,85.0511)  <----- coords (lat, long)
///     0,0                      2^z -1, 0 <---------- Tile number (x,y)
///     +-------------------------+
///     |                         |
///     |            + (0.0,0.0)  |
///     |                         |
///     +-------------------------+
///     0,2^z - 1                 2^z - 1, 2^z - 1
///     (-180,-85.0511)           (180,-85.0511)
///
/// All the wisdom of this class comes from:
/// https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
///
public class TileCoords {
    
    /// Max value of latitude that can be retrieved with tiles (-85.0511 degrees)
    static let maxLatitude : Double = 85.0511
    
    /// Min value of latitude that can be retrieved with tiles (-85.0511 degrees)
    static let minLatitude : Double = -85.0511
    
    /// Max value of a longitude (<180.0).
    /// Any longitude has to be strictly minor than this value 180.0
    static let maxLongitude : Double = 179.99999999
    
    /// Min value of a longitude (>=180.0)
    /// Any longitude has to be mayor or equal to this value -180.0.
    static let minLongitude : Double = -180.0
    
    
    /// Max zoom supported in tile servers (19)
    static let maxZoom : Zoom = 19
    
    /// Min zoom supported (0)
    static let minZoom : Zoom = 0
    
    /// Based on current zoom it indicates what is the max tile
    static public func maxTile(forZoom zoom: Zoom) -> TileNumber {
         return TileNumber(pow(2.0, Double(zoom)) - 1 )
    }
    
    /// Validates if longitude is between min and max allowed longitudes
    ///
    /// - Parameter longitude: the longitude to validate
    /// - Throws: LongitudeError
    /// - SeeAlso: maxLatitude, minLatitude
    static public func validate(longitude: Double) throws -> Void {
        if longitude < minLongitude {
            throw LongitudeError.overflowMin
        } else if longitude > maxLongitude {
            throw LongitudeError.overflowMax
        }
    }
    
    /// Validates if a latitude is between min and max allowed latitudes.
    /// Throws LongitudeError if it is not.
    static public func validate(latitude: Double) throws -> Void {
        if latitude < minLatitude {
            throw LatitudeError.overflowMin
        } else if latitude > maxLatitude {
            throw LatitudeError.overflowMax
        }
    }
    
    /// Validate zoom is less or equal to the maxZoom
    /// Throws ZoomError if is greater than maxZoom
    static public func validate(zoom: Zoom) throws -> Void {
        if zoom > maxZoom {
            throw ZoomError.largerThan19
        }
    }
    
    /// Validates if the tile is within the range for the zoom
    /// A tile must be always be less than 2^zoom.
    static public func validate(tile: TileNumber, forZoom zoom: Zoom) throws -> Void {
        if tile > maxTile(forZoom: zoom) {
            throw TileError.overflow
        }
    }
    
    /// Returns the tile in the X axis for the longitude and zoom.
    /// Can throw ZoomError and LongitudeError if these are out of the boundaries.
    static public func longitudeToTileX(longitude: Double, zoom: Zoom ) throws -> TileNumber {
        try TileCoords.validate(zoom: zoom)
        try TileCoords.validate(longitude: longitude)
        return TileNumber(floor((longitude + 180) / 360.0 * pow(2.0, Double(zoom))))
    }
    
    /// Returns the tile in the Y axis for the latitude and zoom.
    /// Can throw ZoomError and LongitudeError if these are out of the boundaries.
    static public func latitudeToTileY(latitude: Double, zoom: Zoom) throws -> TileNumber{
        try validate(zoom: zoom)
        try validate(latitude: latitude)
        return TileNumber(floor((1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))
    }
    
    /// Returns the corresponding longitude in degrees for the tileX at zoom level
    static public func tileXToLongitude(tileX: TileNumber, zoom: Zoom) throws -> Double {
        try validate(zoom: zoom)
        try validate(tile: tileX, forZoom: zoom)
        let n : Double = pow(2.0, Double(zoom))
        let longitude =  (Double(tileX) / n) * 360.0 - 180.0
        return longitude
    }
    
    /// Returns the corresponding latitude in degrees for the tileY at zoom level
    static public func tileYToLatitude(tileY: TileNumber, zoom: Zoom) throws -> Double {
        try validate(zoom: zoom)
        try validate(tile: tileY, forZoom: zoom)
        let n : Double = pow(2.0, Double(zoom))
        let latitude = atan( sinh (.pi - (Double(tileY) / n) * 2 * Double.pi)) * (180.0 / .pi)
        return latitude
    }
   
    /// Holds the zoom level
    private var _zoom : Zoom = 0
    
    /// Zoom level. Read only. Use setZoom() to change it.
    public var zoom : Zoom {
        get {
            return _zoom
        }
    }
    
    /// Latitude for this tile. Use setCoords() to change it.
    private var _latitude: Double = 0.0
    public var latitude: Double {
        get {
            return _latitude
        }
    }
    
    /// Holds the actual longitude
    private var _longitude: Double = 0.0

    /// Longitude for this tile. Use set() to change it.
    public var longitude: Double {
        get {
            return _longitude
        }
    }
    
    /// Holds the actual tileX
    private var _tileX : TileNumber = 0
    
    /// Tile in the X axis for current longitude and zoom. Use set() to change it.
    public var tileX: TileNumber {
        get {
         return _tileX
        }
    }
    
    // Tile in the Y axis for current latitude and zoom. Use set() to change it.
    private var _tileY: TileNumber = 0
    
    public var tileY : TileNumber {
        get {
            return _tileY
        }
    }
    
    
    /// Set zoom level.
    /// Throws ZoomError if zoom is not valid.
    public func set(zoom: Zoom) throws {
        try TileCoords.validate(zoom: zoom)
        _zoom = zoom
        _tileX = try! TileCoords.longitudeToTileX(longitude: longitude, zoom: _zoom)
        _tileY = try! TileCoords.latitudeToTileY(latitude: latitude, zoom: _zoom)
    }
    
    /// Set tile X and Y values.
    /// Throws TileError if latitude or longitude are out of range.
    public func set(tileX: TileNumber, tileY: TileNumber) throws {
        _longitude = try TileCoords.tileXToLongitude(tileX: tileX, zoom: _zoom)
        _latitude = try TileCoords.tileYToLatitude(tileY: tileY, zoom: _zoom)
        _tileX = tileX
        _tileY = tileY
    }
    
    /// Sets latitude and longitude
    /// Throws LatitudeError and LongitudeError if they are out of range.
    public func set(latitude: Double, longitude: Double) throws {
        
        // validate values are within the ranges
        try TileCoords.validate(latitude: latitude)
        try TileCoords.validate(longitude: longitude)
        
        // set the values
        _latitude = latitude
        _longitude = longitude
        
        //update tiles
        _tileX = try! TileCoords.longitudeToTileX(longitude: longitude, zoom: _zoom)
        _tileY = try! TileCoords.latitudeToTileY(latitude: latitude, zoom: _zoom)
    }
    
    /// Init a TileCoords instance using tile and zoom info.
    /// Will return nil if any of the parameters is out of range.
    public init?(tileX: TileNumber, tileY: TileNumber, zoom: Zoom) {
        do {
            try set(zoom: zoom)
            try set(tileX: tileX, tileY: tileY)
        } catch {
            return nil
        }
    }
    
    /// Init a TileCoords instance using latitude, longitude and zoom info.
    /// Will return nil if any of the parameters is out of range.
    public init?(latitude: Double, longitude: Double, zoom: Zoom) {
        do {
            try set(zoom: zoom)
            try set(latitude: latitude, longitude: longitude)
        } catch {
            return nil
        }
    }
    
    ///
    /// Creates a new Tile Coord with the same latitude and longitude
    /// as the the parameter but with a different zoom
    public init?(_ tileCoords: TileCoords, zoom: Zoom) {
        // we can assume that these are coorect so no need o test.
        self._latitude = tileCoords.latitude
        self._longitude = tileCoords.longitude
        //however zoom is not ok
        do {
            try set(zoom: zoom)
        } catch {
            return nil
        }
    }
    
    /// Returns the maximum tile number for current set zoom.
    public func maxTile() -> TileNumber {
        return TileCoords.maxTile(forZoom: zoom)
    }
}
