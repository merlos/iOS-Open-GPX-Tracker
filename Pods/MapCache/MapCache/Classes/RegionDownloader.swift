//
//  TileDownloader.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation
import MapKit

/// Hey! I need to download this area
/// No problemo.
@objc public class RegionDownloader: NSObject {
    /// Average number of bytes of a tile
    static let defaultAverageTileSizeBytes : UInt64 = 11664
    
    /// region that will be downloaded
    public let region: TileCoordsRegion
    
    /// Cache that is going to be used for saving/loading the files.
    public let mapCache: MapCacheProtocol
    
    /// Total number of tiles to be downloaded
    public var totalTilesToDownload: TileNumber {
        get {
            return region.count
        }
    }
    
    /// Number of tiles pending to be downloaded
    public var pendingTilesToDownload: TileNumber {
        get {
            return region.count - downloadedTiles
        }
    }
    
    
    private var _downloadedBytes: UInt64 = 0
    
    /// Total number of downloaded data bytes
    public var downloadedBytes: UInt64 {
        get {
            return _downloadedBytes
        }
    }
    
    /// Returns the average
    ///
    /// This can be used to estimate the
    public var averageTileSizeBytes: UInt64 {
        get {
            if downloadedTiles != 0 {
                return UInt64(_downloadedBytes / downloadedTiles)
            } else {
                return 0
            }
        }
    }
    
    /// Keeps the number of tiles already downloaded successfully or failed.
    @objc dynamic public var downloadedTiles: TileNumber {
        get {
            return _successfulTileDownloads + _failedTileDownloads
        }
    }
    
    ///
    private var _successfulTileDownloads : TileNumber = 0
    
    /// Keeps the number of tiles already downloaded.
    @objc dynamic public var successfulTileDownloads: TileNumber {
        get {
            return _successfulTileDownloads
        }
    }
    
    /// Keeps the number of tiles failes to be downloaded
    /// Publicly accessible through failledTIleDownloads
    private var _failedTileDownloads : TileNumber = 0
    
    /// Number of tiles to be downloaded
    @objc dynamic public var failedTileDownloads: TileNumber {
        get {
            return _failedTileDownloads
        }
    }
    
    /// Percentage to notify thought delegate
    /// If set to >100 will only notify on finish download
    /// If set to a percentage < `downloadedPercentage`, will never notify.
    public var nextPercentageToNotify: Double = 5.0
    
    /// The downloader will notify the delegate every time this
    /// For example if you set this to 5, it will notify when 5%, 10%, 15%, etc...
    /// default value 5.
    public var incrementInPercentageNotification: Double = 5.0
    
    /// Last notified
    var lastPercentageNotified: Double = 0.0
    
    
    /// Percentage of tiles pending to download.
    public var downloadedPercentage : Double {
        get {
            return 100.0 * Double(downloadedTiles) / Double(totalTilesToDownload)
        }
    }
    
    /// Delegate
    public var delegate : RegionDownloaderDelegate?
    
    
    /// Queue to download stuff.
    lazy var downloaderQueue : DispatchQueue = {
        let queueName = "MapCache.Downloader." + self.mapCache.config.cacheName
        //let downloaderQueue = DispatchQueue(label: queueName, attributes: [])
        let downloaderQueue = DispatchQueue(label: queueName, qos: .background, attributes: [])
        return downloaderQueue
    }()
    
    
    ///
    /// initializes the downloader with the region and the MapCache
    ///
    public init(forRegion region: TileCoordsRegion, mapCache: MapCacheProtocol) {
        self.region = region
        self.mapCache = mapCache
    }
    
    /// Starts download
    public func start() {
        //Downloads stuff
        downloaderQueue.async {
            for range: TileRange in self.region.tileRanges() ?? [] {
                for tileCoords: TileCoords in range {
                    ///Add to the download queue.
                    let mktileOverlayPath = MKTileOverlayPath(tileCoords: tileCoords)
                    self.mapCache.loadTile(at: mktileOverlayPath, result: {data,error in
                        if error != nil {
                            print(error?.localizedDescription ?? "Error downloading tile")
                            self._failedTileDownloads += 1
                        } else {
                            self._successfulTileDownloads += 1
                            print("RegionDownloader:: Donwloaded zoom: \(tileCoords.zoom) (x:\(tileCoords.tileX),y:\(tileCoords.tileY)) \(self.downloadedTiles)/\(self.totalTilesToDownload) \(self.downloadedPercentage)%")
                            
                        }
                        //check if needs to notify duet to percentage
                        if self.downloadedPercentage > self.nextPercentageToNotify {
                            //Update status variables
                            self.lastPercentageNotified = self.nextPercentageToNotify
                            self.nextPercentageToNotify += self.incrementInPercentageNotification
                            //call the delegate
                            self.delegate?.regionDownloader(self, didDownloadPercentage: self.downloadedPercentage)
                        }
                        //Did we finish download
                        if self.downloadedTiles == self.totalTilesToDownload {
                            self.delegate?.regionDownloader(self, didFinishDownload: self.downloadedTiles)
                        }
                    })
                }
            }
        }
    }
    
    /// Returns an estimation of the total number of bytes the whole region may occupy.
    /// It is an estimation.
    public func estimateRegionByteSize() -> UInt64 {
        return RegionDownloader.defaultAverageTileSizeBytes * self.region.count
    }
}
