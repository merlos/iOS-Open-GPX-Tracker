//
//  GPXFileInfo.swift
//  OpenGpxTracker
//
//  Created by merlos on 23/09/2018.
//

import Foundation

///
/// A handy way of getting info of a GPX file.
///
/// It gets info like filename, modified date, filesize
///
class GPXFileInfo: NSObject {
    
    /// file URL
    var fileURL: URL = URL(fileURLWithPath: "")
    
    var modifiedDate: Date {
        guard let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
              let modificationDate = resourceValues.contentModificationDate else {
            return Date.distantPast // Default value if the modification date cannot be retrieved
        }
        return modificationDate
    }
    /// modified date has a time ago string (for instance: 3 days ago)
    var modifiedDatetimeAgo: String {
        return modifiedDate.timeAgo(numericDates: true)
    }
    
    /// File size in bytes
    var fileSize: Int {
        guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
              let size = resourceValues.fileSize else {
            return -1 // Default value if the file size cannot be retrieved
        }
        return size
    }
    
    /// File size as string in a more readable format (example: 10 KB)
    var fileSizeHumanised: String {
        return fileSize.asFileSize()
    }
    
    /// The filename without extension
    var fileName: String {
        return fileURL.deletingPathExtension().lastPathComponent
    }
    
    ///
    /// Initializes the object with the URL of the file to get info.
    ///
    /// - Parameters:
    ///     - fileURL: the URL of the GPX file.
    ///
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
    
}
