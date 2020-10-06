//
//  LoadTileMode.swift
//  MapCache
//
//  Created by merlos on 09/05/2020.
//

import Foundation

/// Defines the strategies that can be used for retrieving the tiles from the cache
/// Used by `MapCache.loadTile()` method.
///
/// - SeeAlso: `MapCache`, `MapCacheConfig`

public enum LoadTileMode {
    
    /// Default. If the tile exists in the cache, return it, otherwise, fetch it from server (and cache the result).
    case cacheThenServer
    
    /// Always return the tile from the server unless there is some problem with the network.
    /// Cache is updated everytime the tile is received.
    /// Basically uses the cache as internet connection fallback
    case serverThenCache
          
    /// Only return data from cache.
    /// Useful for fully offline preloaded maps.
    case cacheOnly
    
    /// Always return the tile from the server, as well as updating the cache.
    /// This mode may be useful for donwloading a whole map region.
    /// If a tile was not downloaded fron the server error is returned.
    case serverOnly
   }
