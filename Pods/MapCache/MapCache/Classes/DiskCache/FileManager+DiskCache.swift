//
//  FileManager+DiskCache.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//

// Original source code from Haneke
//
// https://github.com/Haneke/HanekeSwift/blob/master/Haneke/NSFileManager%2BHaneke.swift
// Created by Hermes Pique on 8/26/14.


import Foundation

extension FileManager {
    
    
    
    func enumerateContentsOfDirectory(atPath path: String, orderedByProperty property: String, ascending: Bool, usingBlock block: (URL, Int, inout Bool) -> Void ) {
        
        let directoryURL = URL(fileURLWithPath: path)
        do {
            let contents = try self.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [URLResourceKey(rawValue: property)], options: FileManager.DirectoryEnumerationOptions())
            let sortedContents = contents.sorted(by: {(URL1: URL, URL2: URL) -> Bool in
                
                // Maybe there's a better way to do this. See: http://stackoverflow.com/questions/25502914/comparing-anyobject-in-swift
                
                var value1 : AnyObject?
                do {
                    try (URL1 as NSURL).getResourceValue(&value1, forKey: URLResourceKey(rawValue: property))
                } catch {
                    return true
                }
                var value2 : AnyObject?
                do {
                    try (URL2 as NSURL).getResourceValue(&value2, forKey: URLResourceKey(rawValue: property))
                } catch {
                    return false
                }
                
                if let string1 = value1 as? String, let string2 = value2 as? String {
                    return ascending ? string1 < string2 : string2 < string1
                }
                
                if let date1 = value1 as? Date, let date2 = value2 as? Date {
                    return ascending ? date1 < date2 : date2 < date1
                }
                
                if let number1 = value1 as? NSNumber, let number2 = value2 as? NSNumber {
                    return ascending ? number1 < number2 : number2 < number1
                }
                
                return false
            })
            
            for (i, v) in sortedContents.enumerated() {
                var stop : Bool = false
                block(v, i, &stop)
                if stop { break }
            }
            
        } catch {
            Log.error(message: "Failed to list directory", error: error)
        }
    }
    
    /// Calculate the allocated size of a directory and all its contents on the volume.
    ///
    /// As there's no simple way to get this information from the file system the method
    /// has to crawl the entire hierarchy, accumulating the overall sum on the way.
    /// The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    func allocatedDiskSizeForDirectory(at directoryURL: URL) throws -> UInt64 {
        
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        
        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ]
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!
        
        // We'll sum up content size here:
        var accumulatedSize: UInt64 = 0
        
        // Perform the traversal.
        for item in enumerator {
            
            // Bail out on errors from the errorHandler.
            if enumeratorError != nil { break }
            
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.regularFileAllocatedDiskSize()
        }
        
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        
        return accumulatedSize
    }
    
    // Calculates the actual sum of file sizes
    func fileSizeForDirectory(at directoryURL: URL) throws -> UInt64 {
        // The error handler simply stores the error and stops traversal
        var enumeratorError: Error? = nil
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileSizeKey
        ]
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!
        
        // We'll sum up content size here:
        var accumulatedSize: UInt64 = 0
        // Perform the traversal.
        for item in enumerator {
            // Bail out on errors from the errorHandler.
            if enumeratorError != nil { break }
            // Add up individual file sizes.
            let contentItemURL = item as! URL
            accumulatedSize += try contentItemURL.regularFileSize()
        }
        // Rethrow errors from errorHandler.
        if let error = enumeratorError { throw error }
        return accumulatedSize
    }
}

func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
    return lhs.compare(rhs) == ComparisonResult.orderedAscending
}


