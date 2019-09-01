//
//  RegionDownloaderDelegate.swift
//  MapCache
//
//  Created by merlos on 18/06/2019.
//

import Foundation

///
/// Delegate protocol of `RegionDownloader`
///
///
@objc public protocol RegionDownloaderDelegate: class {
    
    /// Did download the percentage
    @objc func regionDownloader(_ regionDownloader: RegionDownloader, didDownloadPercentage percentage: Double)
    
    /// Did Finish Download all tiles
    func regionDownloader(_ regionDownloader: RegionDownloader, didFinishDownload tilesDownloaded: TileNumber)
}
