//
//  GPXFileManager.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//

import Foundation

/// GPX File extension
let kFileExt = "gpx"

///
/// Class to handle actions with gpx files (save, delete, etc..)
///
class GPXFileManager: NSObject {
    
    class var GPXFilesFolderURL: URL {
        get {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            return documentsUrl
        }
    }
    
    /// Gets the list of .gpx files in Documents directory ordered by modified date
    class var fileList: [AnyObject] {
        get {
            var GPXFiles: [String] = []
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                do {
                    // Get all files from the directory .documentsURL. Of each file get the URL (~path)
                    // last modification date and file size
                    if let directoryURLs = try? fileManager.contentsOfDirectory(at: documentsURL,
                        includingPropertiesForKeys: [.attributeModificationDateKey, .fileSizeKey],
                        options: .skipsSubdirectoryDescendants) {
                        //Order files based on the date
                        // This map creates a tuple (url: URL, modificationDate: String, filesize: Int)
                        // and then orders it by modificationDate
                        let sortedURLs = directoryURLs.map { url in
                            (url: url,
                             modificationDate: (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast,
                             fileSize: (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                            }
                            .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                        print(sortedURLs)
                        //Now we filter GPX Files
                        for (url, modificationDate, fileSize) in sortedURLs {
                            if url.pathExtension == kFileExt {
                                GPXFiles.append(url.deletingPathExtension().lastPathComponent)
                            }
                        }
                    }
                }
            return GPXFiles as [AnyObject]
        }
    }
    //
    // '@param' filename gpx filename without extension
    class func URLForFilename(_ filename: String) -> URL {
        var fullURL = self.GPXFilesFolderURL.appendingPathComponent(filename)
        //var ext = ".\(kFileExt)" // add dot to file extension
        print("pathForFilename: \(fullURL)")
        //check if filename has extension
        if fullURL.pathExtension != kFileExt {
            print("oh! is not a gpx file")
            fullURL = fullURL.appendingPathExtension(kFileExt)
        }
        return fullURL
    }
    
    //Returns true if the file with filename exists on the default folder. False in othercase.
    class func fileExists(_ filename: String) -> Bool {
        let fileURL = self.URLForFilename(filename)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    ///Saves the GPX contents to the specified URL
    class func saveToURL(_ fileURL: URL, gpxContents: String) {
        //save file
        print("Saving file at path: \(fileURL)")
        // write gpx to file
        var writeError: NSError?
        let saved: Bool
        do {
            try gpxContents.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            saved = true
        } catch let error as NSError {
            writeError = error
            saved = false
        }
        if !saved {
            if let error = writeError {
                print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            }
        }

    }
    
    ///Saves in the default folder the filename with the gpxContents
    class func save(_ filename: String, gpxContents: String) {
        //check if name exists
        let fileURL: URL = self.URLForFilename(filename)
        GPXFileManager.saveToURL(fileURL, gpxContents: gpxContents)
    }
    
    //Removes a file on the specified URL
    class func removeFileFromURL(_ fileURL: URL) {
        print("Removing file at path: \(fileURL)")
        let defaultManager = FileManager.default
        var error: NSError?
        let deleted: Bool
        do {
            try defaultManager.removeItem(atPath: fileURL.path)
            deleted = true
        } catch let error1 as NSError {
            error = error1
            deleted = false
        }
        if !deleted {
            if let e = error {
                print("[ERROR] GPXFileManager:removeFile: \(fileURL) : \(e.localizedDescription)")
            }
        }
    }
    /// Removes file on the default directory for GPX files
    class func removeFile(_ filename: String) {
        let fileURL: URL = self.URLForFilename(filename)
        GPXFileManager.removeFileFromURL(fileURL)
    }
    
    /// Removes all files on the application temporary directory
    class func removeTemporaryFiles() {
        let fileManager = FileManager.default
        do {
            let tmpDirectory = try fileManager.contentsOfDirectory(atPath: NSTemporaryDirectory())
            tmpDirectory.forEach { file in
                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(file)
                GPXFileManager.removeFileFromURL(fileURL)
            }
        } catch {
            print(error)
        }
    }
}
