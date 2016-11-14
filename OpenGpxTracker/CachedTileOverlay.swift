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
        
        //TODO: there shall be a more elegant way to do this replace
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
    
        // for debug purposes
        //return super.url(forTilePath: path)
    }

    
    override func loadTile(at path: MKTileOverlayPath,
                           result: @escaping (Data?, Error?) -> Void) {
        let url = self.url(forTilePath: path)
        //print ("CachedTileOverlay::loadTile() url=\(url)")
        
        if !self.useCache {
            print("CachedTileOverlay:: not using cache")
            return super.loadTile(at: path, result: result)
        }
        //use
        let config = Config(
            frontKind: .memory,  // Your front cache type
            backKind: .disk,  // Your back cache type
            expiry: .date(Date().addingTimeInterval(10000000000)),
            maxSize: 100000)
        let cache = Cache<Data>(name: "ImageCache", config: config)
       
        let cacheKey = "\(self.urlTemplate)-\(path.x)-\(path.y)-\(path.z)"
        //print("CachedTileOverlay::loadTile cacheKey = \(cacheKey)")
        cache.object(cacheKey) { (data: Data?) in
            //result(data, nil
            if data != nil {
                result(data,nil)
            } else {
                //print("Requesting data....");
                let request = URLRequest(url: url)
                NSURLConnection.sendAsynchronousRequest(request, queue: self.operationQueue) {
                    [weak self]
                    response, data, error in
                    if let data = data {
                        cache.add(cacheKey, object: data)
                    }
                    result(data, error)
                }
            }
        }
        //
        
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
