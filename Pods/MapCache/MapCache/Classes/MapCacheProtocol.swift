//
//  MapCacheProtocol.swift
//  MapCache
//
//  Created by merlos on 29/06/2019.
//

import Foundation
import MapKit

public protocol MapCacheProtocol {

    var config: MapCacheConfig { get set }
    
    func url(forTilePath path: MKTileOverlayPath) -> URL
    
    /// Shall load a tile based on MKTileOverlayPath
    func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void)
    
}
