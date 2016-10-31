//
//  CachedTileOverlay.swift
//  OpenGpxTracker
//
//  Created by merlos on 31/10/2016.
// 
//

import Foundation
import MapKit

/**
 * Overwrites the default overlay to store downloaded images
 */

class CachedTileOverlay : MKTileOverlay {
    let cache = NSCache<AnyObject, AnyObject>()
    let operationQueue = OperationQueue()
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        
        //TODO: there shall be a more elegant way to do this replace
        //var urlString = urlTemplate?.replacingOccurrences(of: "{z}", with: String(path.z))
        //urlString = urlString?.replacingOccurrences(of: "{x}", with: String(path.x))
        //urlString = urlString?.replacingOccurrences(of: "{y}", with: String(path.y))
        //print("CachedTileOverlay:: url() urlString: \(urlString)")
        //let urlString = "http://tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y)"
        //return URL(string: urlString)!
        return super.url(forTilePath: path)
    }
    
    override func loadTile(at path: MKTileOverlayPath,
                           result: @escaping (Data?, Error?) -> Void) {
        //let url = self.url(forTilePath: path)
        //print ("CachedTileOverlay::loadTile() url=\(url)")
        return super.loadTile(at: path, result: result)
        
        /*if let cachedData = cache.objectForKey(url as AnyObject) as? NSData {
            result(cachedData, nil)
        } else {
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: operationQueue) {
                [weak self]
                response, data, error in
                if let data = data {
                    self?.cache.setObject(data, forKey: url)
                }
                result(data, error)
            }
        }
         */
        
    }
}
