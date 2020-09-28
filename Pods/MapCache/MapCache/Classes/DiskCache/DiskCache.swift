//
//  DiskCache.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//
// Based on Haneke Disk Cache
// https://github.com/Haneke/HanekeSwift
//

import Foundation

///
/// A specialized cache for storing data in disk.
/// Based on [Haneke Disk Cache](https://github.com/Haneke/HanekeSwift) and customized for the MapCache project.
///
open class DiskCache {
    
    /// Gets the root base folder to be used.
    open class func baseURL() -> URL {
        // where should you put your files
        // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let baseURL = URL(fileURLWithPath: cachePath, isDirectory: true).appendingPathComponent("DiskCache", isDirectory: true)
        return baseURL
    }
    
    /// URL of the physical folder of the Cache in the file system.
    public let folderURL: URL
    
    /// A shortcut for `folderURL.path`.
    open var path: String {
        get {
            return self.folderURL.path
        }
    }
    
    /// Sum of the allocated size in disk for the cache expressed in bytes.
    ///
    /// Note that, this size is the actual disk allocation. It is equivalent with the amount of bytes
    /// that would become available on the volume if the directory is deleted.
    ///
    /// For example, a file may just contain 156 bytes of data (size listed in `ls` command), however its
    /// disk size is 4096, 1 volume block (as listed using `du -h`)
    ///
    /// This size is calculated each time
    open var diskSize : UInt64 = 0
    
    /// This is the sum of the data sizes of the files within the `DiskCache`
    ///
    /// This size is calculated each time it is used
    /// - Seealso: `diskSize`
    
    open var fileSize: UInt64? {
        return try? FileManager.default.fileSizeForDirectory(at: folderURL)
    }
    
    /// Maximum allowed cache disk allocated size for this `DiskCache``
    /// Defaults to unlimited capacity (`UINT64_MAX`)
    open var capacity : UInt64 = UINT64_MAX {
        didSet {
            self.cacheQueue.async(execute: {
                self.controlCapacity()
            })
        }
    }
    
    /// Queue for making async operations.
    open lazy var cacheQueue : DispatchQueue = {
        let queueName = "DiskCache.\(folderURL.lastPathComponent)"
        let cacheQueue = DispatchQueue(label: queueName, attributes: [])
        return cacheQueue
    }()
    
    /// Constructor
    /// - Parameter withName: Name of the cache, will be the subfolder name too.
    /// - Parameter capacity: capacity of the cache in bytes. Defaults to virutally unlimited capacity (`UINT64_MAX`)
    public init(withName cacheName: String, capacity: UInt64 = UINT64_MAX) {
        folderURL = DiskCache.baseURL().appendingPathComponent(cacheName, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: self.folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Log.error(message: "Failed to create directory \(folderURL.absoluteString)", error: error)
        }
        self.capacity = capacity
        cacheQueue.async(execute: {
            self.diskSize = self.calculateDiskSize()
            self.controlCapacity()
        })
        //Log.debug(message: "DiskCache folderURL=\(folderURL.absoluteString)")
    }
    
    
    /// Get the path for key.
    open func path(forKey key: String) -> String {
        return self.folderURL.appendingPathComponent(key.toMD5()).path
    }
    
    /// Sets the data for the key asyncronously.
    /// Use this function for writing into the cache.
    open func setData( _ data: Data, forKey key: String) {
        cacheQueue.async(execute: {
            self.setDataSync(data, forKey: key)
        })
    }
    
    /// Sets the data for the key synchronously.
    open func setDataSync(_ data: Data, forKey key: String) {
        let filePath = path(forKey: key)
        
        //If the file exists get the current file diskSize.
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            substract(diskSize: try fileURL.regularFileAllocatedDiskSize())
        } catch {} //if file is not found do nothing
        
        do {
            try data.write(to: URL(fileURLWithPath: filePath), options: Data.WritingOptions.atomicWrite)
        } catch {
            Log.error(message: "Failed to write key \(key)", error: error)
        }
        //Now add to the diskSize the file size
        var diskBlocks = Double(data.count) / 4096.0
        diskBlocks.round(.up)
        diskSize += UInt64(diskBlocks * 4096.0)
        self.controlCapacity()
    }
    
    /// Fetches the image data from storage synchronously.
    ///
    /// - Parameter forKey: Key within the cache
    /// - Parameter failure: closure to be run in case of error
    /// - Parameter success: closure to be run once the data is ready
    ///
    open func fetchDataSync(forKey key: String, failure fail: ((Error?) -> ())? = nil, success succeed: @escaping (Data) -> ()) {
        let path = self.path(forKey: key)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions())
            succeed(data)
            self.updateDiskAccessDate(atPath: path)
        } catch {
            if let block = fail {
                block(error)
            }
        }
    }
    
    /// Removes asynchronously the data from the diskcache for the key passed as argument.
    /// - Parameter withKey: key to be removed
    open func removeData(withKey key: String) {
        cacheQueue.async(execute: {
            let path = self.path(forKey: key)
            self.removeFile(atPath: path)
        })
    }
    
    /// Removes asynchronously all data from the cache.
    /// Calls completition closure once the task is done.
    /// - Parameter completition: closure run once all the files are deleted from the cache
    open func removeAllData(_ completion: (() -> ())? = nil) {
        let fileManager = FileManager.default
        cacheQueue.async(execute: {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: self.path)
                for filename in contents {
                    let filePath = self.folderURL.appendingPathComponent(filename).path
                    do {
                        try fileManager.removeItem(atPath: filePath)
                        print(" ------------- Removed path \(filename)")
                    } catch {
                        Log.error(message: "Failed to remove path \(filePath)", error: error)
                    }
                }
                self.diskSize = self.calculateDiskSize()
                print("++++++++++++++++ Size at the end \(self.diskSize)")
            } catch {
                Log.error(message: "Failed to list directory", error: error)
            }
            if let completion = completion {
                DispatchQueue.main.async {
                    completion()
                }
            }
        })
    }
    
    /// Removes the cache from the system.
    /// This method not only removes the data, it also removes the cache folder.
    ///
    /// Do not call any method after removing the cache, create a new instance instead.
    ///
    open func removeCache() {
        do {
            try FileManager.default.removeItem(at: self.folderURL)
        } catch {
            Log.error(message: "ERROR removing DiskCache folder", error: error)
        }
    }
    
    /// Asynchronously updates the access date of a file.
    open func updateAccessDate( _ getData: @autoclosure @escaping () -> Data?, key: String) {
        cacheQueue.async(execute: {
            let path = self.path(forKey: key)
            let fileManager = FileManager.default
            if (!(fileManager.fileExists(atPath: path) && self.updateDiskAccessDate(atPath: path))){
                if let data = getData() {
                    self.setDataSync(data, forKey: key)
                } else {
                    Log.error(message: "Failed to get data for key \(key)")
                }
            }
        })
    }
    
    /// Calculates the size used by all the files in the cache.
    public func calculateDiskSize() -> UInt64 {
        let fileManager = FileManager.default
        var currentSize : UInt64 = 0
        do {
            currentSize = try fileManager.allocatedDiskSizeForDirectory(at: folderURL)
        }
        catch {
            Log.error(message: "Failed to get diskSize of directory", error: error)
        }
        return currentSize
    }
    
    // MARK: Private
    
    /// It checks if the capacity of the cache has been reached. If so, it removes the least recently used file (LRU).
    fileprivate func controlCapacity() {
        if self.diskSize <= self.capacity { return }
        
        let fileManager = FileManager.default
        let cachePath = self.path
        fileManager.enumerateContentsOfDirectory(
            atPath: cachePath,
            orderedByProperty: URLResourceKey.contentModificationDateKey.rawValue, ascending: true) {
                (URL : URL, _, stop : inout Bool) -> Void in
                self.removeFile(atPath: URL.path)
                stop = self.diskSize <= self.capacity
        }
    }
    /// Updates the time a file was accessed for the last time.
    @discardableResult fileprivate func updateDiskAccessDate(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        let now = Date()
        do {
            try fileManager.setAttributes([FileAttributeKey.modificationDate : now], ofItemAtPath: path)
            return true
        } catch {
            Log.error(message: "Failed to update access date", error: error)
            return false
        }
    }
    
    /// Removes a file syncrhonously.
    fileprivate func removeFile(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let fileURL = URL(fileURLWithPath: path)
            let fileSize = try fileURL.regularFileAllocatedDiskSize()
            try fileManager.removeItem(atPath: path)
            substract(diskSize: fileSize)
        } catch {
            if isNoSuchFileError(error) {
                Log.error(message: "Failed to remove file. File not found", error: error)
            } else {
                Log.error(message: "Failed to remove file. Size or other error", error: error)
            }
        }
    }
    
    /// Substracts from the cachesize  the disk size passed as parameter.
    /// Logs an error message if the amount to be substracted is larger than the current used disk space.
    ///
    /// - Parameter diskSize: disksize to be deducted
    fileprivate func substract(diskSize : UInt64) {
        if (self.diskSize >= diskSize) {
            self.diskSize -= diskSize
        } else {
            Log.error(message: "Disk cache diskSize (\(self.diskSize)) is smaller than diskSize to substract (\(diskSize))")
            self.diskSize = 0
        }
    }
}

/// Error when there is not a file.
private func isNoSuchFileError(_ error : Error?) -> Bool {
    if let error = error {
        return NSCocoaErrorDomain == (error as NSError).domain && (error as NSError).code == NSFileReadNoSuchFileError
    }
    return false
}
