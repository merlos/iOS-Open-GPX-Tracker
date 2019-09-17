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

open class DiskCache {
    
    //TODO REMOVE
    open class func baseURL() -> URL {
        
        // where should you put your files
        // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let baseURL = URL(fileURLWithPath: cachePath, isDirectory: true).appendingPathComponent("DiskCache", isDirectory: true)
        return baseURL
    }
    
    /// URL of the physical folder of the Cache in the file system
    public let folderURL: URL
    
    /// A shortcut for folderURL.path
    open var path: String {
        get {
            return self.folderURL.path
        }
    }
    /// Current cache size
    open var size : UInt64 = 0
    
    open var capacity : UInt64 = 0 {
        didSet {
            self.cacheQueue.async(execute: {
                self.controlCapacity()
            })
        }
    }
    
    open lazy var cacheQueue : DispatchQueue = {
        let queueName = "DiskCache.\(folderURL.lastPathComponent)"
        let cacheQueue = DispatchQueue(label: queueName, attributes: [])
        return cacheQueue
    }()
    
    public init(withName cacheName: String, capacity: UInt64 = UINT64_MAX) {
        folderURL = DiskCache.baseURL().appendingPathComponent(cacheName, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: self.folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Log.error(message: "Failed to create directory \(folderURL.absoluteString)", error: error)
        }
        self.capacity = capacity
        cacheQueue.async(execute: {
            self.size = self.calculateSize()
            self.controlCapacity()
        })
        //Log.debug(message: "DiskCache folderURL=\(folderURL.absoluteString)")
    }
    
    
    /// Gets paths for key
    open func path(forKey key: String) -> String {
        return self.folderURL.appendingPathComponent(key.toMD5()).path
        //let escapedFilename = key.escapedFilename()
        //let filename = escapedFilename.count < Int(NAME_MAX) ? escapedFilename : key.MD5Filename()
        //return self.folderURL.appendingPathComponent(filename).path
    }
    
    /// Sets the data for the key asyncronously
    /// Use this function for writing into the cache
    open func setData( _ data: Data, forKey key: String) {
        cacheQueue.async(execute: {
                self.setDataSync(data, forKey: key)
        })
    }
    
    /// Sets the data for the key synchronously
    open func setDataSync(_ data: Data, forKey key: String) {
        let path = self.path(forKey: key)
        let fileManager = FileManager.default
        let previousAttributes : [FileAttributeKey: Any]? = try? fileManager.attributesOfItem(atPath: path)
        
        do {
            try data.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomicWrite)
        } catch {
            Log.error(message: "Failed to write key \(key)", error: error)
        }
        
        if let attributes = previousAttributes {
            if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                substract(size: fileSize)
            }
        }
        self.size += UInt64(data.count)
        self.controlCapacity()
    }
    
    
    open func fetchData(forKey key: String, failure fail: ((Error?) -> ())? = nil, success succeed: @escaping (Data) -> ()) {
        cacheQueue.async {
            let path = self.path(forKey: key)
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: Data.ReadingOptions())
                DispatchQueue.main.async {
                    succeed(data)
                }
                self.updateDiskAccessDate(atPath: path)
            } catch {
                if let block = fail {
                    DispatchQueue.main.async {
                        block(error)
                    }
                }
            }
        }
    }
    
    open func removeData(withKey key: String) {
        cacheQueue.async(execute: {
            let path = self.path(forKey: key)
            self.removeFile(atPath: path)
        })
    }
    
    open func removeAllData(_ completion: (() -> ())? = nil) {
        let fileManager = FileManager.default
        cacheQueue.async(execute: {
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: self.path)
                for filename in contents {
                    let filePath = self.folderURL.appendingPathComponent(filename).path
                    do {
                        try fileManager.removeItem(atPath: filePath)
                    } catch {
                        Log.error(message: "Failed to remove path \(filePath)", error: error)
                    }
                }
                self.size = self.calculateSize()
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
    
    public func calculateSize() -> UInt64 {
        let fileManager = FileManager.default
        var currentSize : UInt64 = 0
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            for pathComponent in contents {
                let filePath = folderURL.appendingPathComponent(pathComponent).path
                do {
                    let attributes: [FileAttributeKey: Any] = try fileManager.attributesOfItem(atPath: filePath)
                    if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                        currentSize += fileSize
                    }
                } catch {
                    Log.error(message: "Failed to list directory", error: error)
                }
            }
            
        } catch {
            Log.error(message: "Failed to list directory", error: error)
        }
        return currentSize
    }
    
    // MARK: Private
    
    fileprivate func controlCapacity() {
        if self.size <= self.capacity { return }
        
        let fileManager = FileManager.default
        let cachePath = self.path
        fileManager.enumerateContentsOfDirectory(
            atPath: cachePath,
            orderedByProperty: URLResourceKey.contentModificationDateKey.rawValue, ascending: true) {
                (URL : URL, _, stop : inout Bool) -> Void in
                self.removeFile(atPath: URL.path)
                stop = self.size <= self.capacity
        }
    }
    
    
    
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
    
    fileprivate func removeFile(atPath path: String) {
        let fileManager = FileManager.default
        do {
            let attributes: [FileAttributeKey: Any] = try fileManager.attributesOfItem(atPath: path)
            do {
                try fileManager.removeItem(atPath: path)
                if let fileSize = attributes[FileAttributeKey.size] as? UInt64 {
                    substract(size: fileSize)
                }
            } catch {
                Log.error(message: "Failed to remove file", error: error)
            }
        } catch {
            if isNoSuchFileError(error) {
                Log.debug(message: "File not found", error: error)
            } else {
                Log.error(message: "Failed to remove file", error: error)
            }
        }
    }
    
    fileprivate func substract(size : UInt64) {
        if (self.size >= size) {
            self.size -= size
        } else {
            Log.error(message: "Disk cache size (\(self.size)) is smaller than size to substract (\(size))")
            self.size = 0
        }
    }
}

private func isNoSuchFileError(_ error : Error?) -> Bool {
    if let error = error {
        return NSCocoaErrorDomain == (error as NSError).domain && (error as NSError).code == NSFileReadNoSuchFileError
    }
    return false
}
