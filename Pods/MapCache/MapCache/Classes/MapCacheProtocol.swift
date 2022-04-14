//
//  MapCacheProtocol.swift
//  MapCache
//
//  Created by merlos on 29/06/2019.
//

import Foundation
import MapKit

///
///  This protocol shall be implemented by any cache used in MapCache.
///
/// - SeeAlso: [Main Readme page](/)
///
public protocol MapCacheProtocol {

    /// An instance of `MapCacheConfig`
    var config: MapCacheConfig { get set }
    
    /// The implementation shall convert a tile path into a URL object
    ///
    /// Typically it will use the `config.urlTemplate` and `config.subdomains`.
    ///
    /// An example of implementation can be found in the class`MapCache`
    func url(forTilePath path: MKTileOverlayPath) -> URL
    
    ///
    /// The implementation shall return either the tile as a Data object or an Error if the tile could not be retrieved.
    ///
    /// - SeeAlso [MapKit.MkTileOverlay](https://developer.apple.com/documentation/mapkit/mktileoverlay)
    func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void)
    
}
