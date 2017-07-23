//
//  CachedTileOverlay.swift
//  OpenGpxTracker
//
//  Created by merlos on 31/10/2016.
// 
//

import Foundation
import MapKit
import Cache

/**
 * Overwrites the default overlay to store downloaded images
 */

class CachedTileOverlay : MKTileOverlay {
    let operationQueue = OperationQueue()
    var useCache: Bool = true
    
   override func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        var urlString = urlTemplate?.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString?.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString?.replacingOccurrences(of: "{y}", with: String(path.y))
    
        //get random subdomain
        let subdomains = "abc"
        let rand = arc4random_uniform(UInt32(subdomains.characters.count))
        let randIndex = subdomains.index(subdomains.startIndex, offsetBy: String.IndexDistance(rand));
        urlString = urlString?.replacingOccurrences(of: "{s}", with:String(subdomains[randIndex]))
        //print("CachedTileOverlay:: url() urlString: \(urlString)")
        return URL(string: urlString!)!
    }

    
    override func loadTile(at path: MKTileOverlayPath,
                           result: @escaping (Data?, Error?) -> Void) {
        let url = self.url(forTilePath: path)
        //print ("CachedTileOverlay::loadTile() url=\(url)")
        
        if !self.useCache {
            print("CachedTileOverlay:: not using cache")
            return super.loadTile(at: path, result: result)
        }
        //use this config
        let config = Config(
            // Expiry date that will be applied by default for every added object
            // if it's not overridden in the add(key: object: expiry: completion:) method
            expiry: .date(Date().addingTimeInterval(604800)), // 7 days
            /// The maximum number of objects in memory the cache should hold
            memoryCountLimit: 0,
            /// The maximum total cost that the cache can hold before it starts evicting objects
            memoryTotalCostLimit: 0,
            /// Maximum size of the disk cache storage (in bytes)
            maxDiskSize: 5000000, // 50 MB cache for all your local content to use without GPS signal
            // Where to store the disk cache. If nil, it is placed in an automatically generated directory in Caches
            cacheDirectory: NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask,
                                                                true).first! + "/cache-in-documents"
        )
        let cache = SpecializedCache<Data>(name: "ImageCache", config: config)
        let cacheKey = "\(self.urlTemplate ?? "none")-\(path.x)-\(path.y)-\(path.z)"
        print("CachedTileOverlay::loadTile cacheKey = \(cacheKey)")
        
        // Get object from cache
        cache.async.object(forKey: cacheKey) { (cacheData: Data?) in
            if let cacheData = cacheData {
                result(cacheData, nil)
            } else  {
                print("Requesting data....");
                let request = URLRequest(url: url)
                NSURLConnection.sendAsynchronousRequest(request, queue: self.operationQueue) {
                    response, data, error in
                    if let data = data {
                        // Add object to cache
                        cache.async.addObject(data, forKey: cacheKey) { error in
                            if let error = error {
                                print(error)
                                result(nil, error)
                            } else {
                                result(data, nil)
                            }
                        }
                    }
                }
            }
        }
        
        do {
            let size = try cache.totalDiskSize()
            print("cache size \(size)")
        } catch {
            print("cache size could not be retrieved")
        }
        
    }
}
