//
//  File.swift
//  MapCache
//
//  Created by merlos on 23/11/2019.
//

import Foundation

extension URL {
    
    /// Returns the allocated size in disk for a regular file in bytes.
    /// Typically are multiples of 4096 bytes
    func regularFileAllocatedDiskSize() throws -> UInt64 {
        
        let allocatedSizeResourceKeys: Set<URLResourceKey> = [
            .isRegularFileKey,
            .fileAllocatedSizeKey,
            .totalFileAllocatedSizeKey,
        ]
        
        let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)

        // We only look at regular files.
        guard resourceValues.isRegularFile ?? false else {
            return 0
        }

        // To get the file's size we first try the most comprehensive value in terms of what
        // the file may use on disk. This includes metadata, compression (on file system
        // level) and block size.
        // In case totalFileAllocatedSize is unavailable we use the fallback value (excluding
        // meta data and compression) This value should always be available.
        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }
    
    
    /// Returns the allocated file a regular file in bytes
      func regularFileSize() throws -> UInt64 {
          let allocatedSizeResourceKeys: Set<URLResourceKey> = [
              .isRegularFileKey,
              .fileSizeKey,
          ]
          let resourceValues = try self.resourceValues(forKeys: allocatedSizeResourceKeys)
          // We only look at regular files.
          guard resourceValues.isRegularFile ?? false else {
              return 0
          }
        return UInt64(resourceValues.fileSize ?? 0)
      }
}
