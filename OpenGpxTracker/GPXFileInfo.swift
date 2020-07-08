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
    
    /// Last time the file was modified
    var modifiedDate: Date {
        // swiftlint:disable force_try
        return try! fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
    }
    
    /// modified date has a time ago string (for instance: 3 days ago)
    var modifiedDatetimeAgo: String {
        return modifiedDate.timeAgo(numericDates: true)
    }
    
    /// File size in bytes
    var fileSize: Int {
        // swiftlint:disable force_try
        return try! fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
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
