//
//  MapCache.swift
//  MapCache
//
//  Created by merlos on 13/05/2019.
//

import Foundation
import MapKit


/// The real brain
public class MapCache : MapCacheProtocol {
    
    public var config : MapCacheConfig
    public var diskCache : DiskCache
    let operationQueue = OperationQueue()
    
    public init(withConfig config: MapCacheConfig ) {
        self.config = config
        diskCache = DiskCache(withName: config.cacheName, capacity: config.capacity)
    }
    
    public func url(forTilePath path: MKTileOverlayPath) -> URL {
        //print("CachedTileOverlay:: url() urlTemplate: \(urlTemplate)")
        var urlString = config.urlTemplate.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString.replacingOccurrences(of: "{y}", with: String(path.y))
        urlString = urlString.replacingOccurrences(of: "{s}", with: config.roundRobinSubdomain() ?? "")
        print("MapCache::url() urlString: \(urlString)")
        return URL(string: urlString)!
    }
    
    public func cacheKey(forPath path: MKTileOverlayPath) -> String {
        return "\(config.urlTemplate)-\(path.x)-\(path.y)-\(path.z)"
    }
    
    public func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        // Use cache
        // is the file alread in the system?
        let key = cacheKey(forPath: path)
        
        
        // If fetching data from cache is successfull => return the data
        let fetchSuccess = {(data: Data) -> () in
            print ("MapCache::loadTile() found! cacheKey=\(key)" )
            result (data, nil)
            return
        }
        // Closure to run if error found while fetching data from cache
        let fetChfailure = { (error: Error?) -> () in
            print ("MapCache::loadTile() Not found! cacheKey=\(key)" )
        }
        // Fetch the data
        diskCache.fetchData(forKey: key, failure: fetChfailure, success: fetchSuccess)
        let url = self.url(forTilePath: path)
        print ("MapCache::loadTile() url=\(url)")
        print("Requesting data....");
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error != nil {
                print("!!! MapCache::loadTile Error for key= \(key)")
                //print(error)
                result(nil,error)
                return
            }
            guard let data = data else { return }
            self.diskCache.setData(data, forKey: key)
            print ("CachedTileOverlay:: Data received saved cacheKey=\(key)" )
            result(data,nil)
        }
        task.resume()
    }
    
    public var diskSize: UInt64 {
        get  {
            return diskCache.diskSize
        }
    }
    
    public func calculateDiskSize() -> UInt64 {
        return diskCache.calculateDiskSize()
    }
    
    public func clear(completition: (() -> ())? ) {
        diskCache.removeAllData(completition)
    }
    
}
