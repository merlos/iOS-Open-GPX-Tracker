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
        //TODO --- It seems inapropriate to initialize the cache in this method. Move move it out.
        //use this config
        let diskConfig = DiskConfig(
            // The name of disk storage, this will be used as folder name within directory
            name: "ImageCache",
            // Expiry date that will be applied by default for every added object
            // if it's not overridden in the `setObject(forKey:expiry:)` method
            expiry: .date(Date().addingTimeInterval(60*24*3600)), //60 days
            // Maximum size of the disk cache storage (in bytes)
            maxSize: 500 * 1000 * 1000, //= 500 MB
            // Where to store the disk cache. If nil, it is placed in `cachesDirectory` directory.
            directory: nil
        )
        let memoryConfig = MemoryConfig(
            // Expiry date that will be applied by default for every added object
            // if it's not overridden in the `setObject(forKey:expiry:)` method
            expiry: .date(Date().addingTimeInterval(2*60)),
            /// The maximum number of objects in memory the cache should hold
            countLimit: 50,
            /// The maximum total cost that the cache can hold before it starts evicting objects
            totalCostLimit: 0
        )
        let cache = try? Storage(
            diskConfig: diskConfig,
            memoryConfig: memoryConfig,
            transformer: TransformerFactory.forCodable(ofType: Data.self) // Storage<User>
        )
        let cacheKey = "\(self.urlTemplate ?? "none")-\(path.x)-\(path.y)-\(path.z)"
        print("CachedTileOverlay::loadTile cacheKey = \(cacheKey)")
        cache?.async.object(forKey: cacheKey) { object in
            switch object {
            case .value(let cached):
                print("Object found in cache!!!!")
                result(cached,nil)
            case .error:
                print("CachedTileOverlay:LoadTile. Error no such object")
                print("Requesting data....");
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        result(nil,error)
                        return
                    }
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else {
                            DispatchQueue.main.async {
                                result(nil, error)
                            }
                            return
                    }
                    //let data = data
                    //save data in cache
                    cache?.async.setObject(data!, forKey: cacheKey) { error in
                        if error == nil {
                            print("ERROR saving in cache: \(error)")
                        }
                    }
                    DispatchQueue.main.async {
                        result(data, nil)
                    }
                } // dataTask
                task.resume()
            }
        }

        // Get object from cache
        /* cache.async.object(forKey: cacheKey) { (cacheData: Data?) in
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
        }*/
        
        /*
        do {
            let size = try cache.totalDiskSize()
            print("cache size \(size)")
        } catch {
            print("cache size could not be retrieved")
        }
        */
    }
}
