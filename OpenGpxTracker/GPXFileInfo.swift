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
    
    /// Cached modified date. Assumes a short lived time. It keeps the value of the size that only once is retrived from the filesystem
    var _modifiedDate: Date?
    
    /// Cached filesize. Assuming a short lived time it keeps the value so only once is retrieved
    var _fileSize: Int?
    
    /// file URL
    var fileURL: URL = URL(fileURLWithPath: "")
    
    /// Returns last time the file was modified
    /// The date is cached in the internal variable _modifiedDate,.
    /// If for some reason the date cannot be retrieved it returns `Date.distantPast`
    ///
    var modifiedDate: Date {
        if _modifiedDate != nil {
            return _modifiedDate!
        }
        guard let resourceValues = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
              let _modifiedDate = resourceValues.contentModificationDate else {
            return Date.distantPast // Default value if the modification date cannot be retrieved
        }
        return _modifiedDate
    }
    /// modified date has a time ago string (for instance: 3 days ago)
    var modifiedDatetimeAgo: String {
        return modifiedDate.timeAgo(numericDates: true)
    }
    
    /// File size in bytes
    /// It returns -1 if there is any issue geting the size from the filesystem
    /// It caches the values in _filezise
    var fileSize: Int {
        if (_fileSize != nil) {
            return _fileSize!
        }
        guard let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
              let _filesize = resourceValues.fileSize else {
            return -1 // Default value if the file size cannot be retrieved
        }
        return _filesize
    }
    
    /// File size as string in a more readable format (example: 10 KB)
    var fileSizeHumanised: String {
        return fileSize.asFileSize()
    }
    
    /// The filename without extension
    /// Example:
    ///  /path/to/file.ext => file
    ///
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
