//
//  GPXFileManager.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//

import Foundation

///
/// Class to handle actions with GPX files (save, delete, etc..)
///
/// It works on the default document directory of the app.
///
class GPXFileManager: NSObject {
    
    /// List of GPX File extension
    static let gpxExtList = ["gpx", "GPX"]

    ///
    /// Folder that where all GPX files are stored
    ///
    class var GPXFilesFolderURL: URL {
        if let customFolderURL = Preferences.shared.gpxFilesFolderURL {
            print("GPXFileManager: using custom folder: \(customFolderURL)")
            return customFolderURL
        }
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        return documentsUrl
    }
    
    ///
    /// Gets the list of `.gpx` files in Documents directory ordered by modified date
    ///
    class var fileList: [GPXFileInfo] {
        let documentsURL = GPXFileManager.GPXFilesFolderURL
        let secured = documentsURL.startAccessingSecurityScopedResource()
        let files = self.fetchFilesList(from: documentsURL)
        if secured {
            documentsURL.stopAccessingSecurityScopedResource()
        }
        return files
    }
    
    ///
    /// Provides the URL in the GPXFilesFolderURL for the filename provided as argument.
    ///
    /// - Parameters:
    ///     - filename: gpx filename with .gpx extension (f.i: `hola.gpx`) or without extension (f.i: `hola`)
    ///
    class func URLForFilename(_ filename: String) -> URL {
        var fullURL = self.GPXFilesFolderURL.appendingPathComponent(filename)
        print("URLForFilename(\(filename): pathForFilename: \(fullURL)")
        // Check if filename has extension
        if  !(gpxExtList.contains(fullURL.pathExtension)) {
            fullURL = fullURL.appendingPathExtension(gpxExtList[0])
        }
        return fullURL
    }
    
    ///
    /// Returns true if the file with filename exists on the default folder (GPXFilesFolderURL).
    /// False in othercase.
    ///
    /// - Parameters:
    ///     - filename: Name of the file without extension.
    class func fileExists(_ filename: String) -> Bool {
        let fileURL = self.URLForFilename(filename)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    ///
    /// Saves the GPX contents to the specified URL
    /// - Parameters:
    ///     - fileURL: destination URL, basically it is file path.
    ///     - gpxContents: String with the contents to be saved. The XML contents of the GPX file
    /// - Returns: `nil` on success, or the `Error` that caused the write to fail.
    ///
    @discardableResult
    class func saveToURL(_ fileURL: URL, gpxContents: String) -> Error? {
        // Save file
        print("Saving file at path: \(fileURL)")
        // When the GPX files folder is a user-picked location (f.i. an iCloud
        // Drive folder), the folder URL is security-scoped and must be unlocked
        // before we can write into it. This mirrors what `fileList` does for reads.
        let folderURL = GPXFileManager.GPXFilesFolderURL
        let secured = folderURL.startAccessingSecurityScopedResource()
        defer {
            if secured {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }
        // write gpx to file
        do {
            try gpxContents.write(toFile: fileURL.path, atomically: true, encoding: String.Encoding.utf8)
            return nil
        } catch {
            print("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            return error
        }
    }
    ///
    /// Saves in the default folder the filename with the gpxContents
    ///
    /// - Parameters:
    ///     - filename: gpx filename with .gpx extension (f.i: `hola.gpx`) or without extension (f.i: `hola`)
    ///     - gpxContents: String with the contents to be saved. The XML contents of the GPX file
    /// - Returns: `nil` on success, or the `Error` that caused the write to fail.
    ///
    @discardableResult
    class func save(_ filename: String, gpxContents: String) -> Error? {
        // Check if name exists
        let fileURL: URL = self.URLForFilename(filename)
        return GPXFileManager.saveToURL(fileURL, gpxContents: gpxContents)
    }
    
    ///
    /// Moves temporary files received from Apple Watch app to default directory
    ///
    /// - Parameters:
    ///     - fileURL: URL of temporary file that should be moved/saved.
    ///     - fileName: name of temporary file, including the file extension (`.gpx`)
    ///
    class func moveFrom(_ fileURL: URL, fileName: String?) {
        
        // check if file name is valid
        guard let fileName = fileName else {
            print("GPXFileManager:: save failed, error: file name is nil")
            return
        }
        
        // The destination folder may be a security-scoped user-picked location
        // (f.i. an iCloud Drive folder), so unlock it before moving into it.
        let folderURL = GPXFilesFolderURL
        let secured = folderURL.startAccessingSecurityScopedResource()
        defer {
            if secured {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }
        // attempt to move file
        do {
            let url = folderURL.path + "/" + fileName
            try FileManager().moveItem(atPath: fileURL.path, toPath: url)
        }

        // file move failure
        catch {
            print("GPXFileManager:: save failed, error: \(error)")
        }
    }
    
    /// Removes a file on the specified URL
    class func removeFileFromURL(_ fileURL: URL) {
        print("Removing file at path: \(fileURL)")
        // The file may live in a security-scoped user-picked folder (f.i. an
        // iCloud Drive folder), so unlock it before attempting to delete.
        let folderURL = GPXFileManager.GPXFilesFolderURL
        let secured = folderURL.startAccessingSecurityScopedResource()
        defer {
            if secured {
                folderURL.stopAccessingSecurityScopedResource()
            }
        }
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
    ///
    /// Removes file on the default directory for GPX files
    ///
    /// - Parameters:
    ///     - filename: gpx filename with .gpx extension (f.i: `hola.gpx`) or without extension (f.i: `hola`)
    ///
    class func removeFile(_ filename: String) {
        let fileURL: URL = self.URLForFilename(filename)
        GPXFileManager.removeFileFromURL(fileURL)
    }
    
    ///
    /// Removes all files on the application temporary directory (NSTemporaryDirectory())
    ///
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
    
    // MARK: - Private
    
    private class func fetchFilesList(from rootURL: URL) -> [GPXFileInfo] {
        var GPXFiles: [GPXFileInfo] = []
        let fileManager = FileManager.default
        print("====================================================================")
        do {
            // Get all files from the directory .documentsURL. Of each file get the URL (~path)
            // last modification date and file size
            if let directoryURLs = try? fileManager.contentsOfDirectory(at: rootURL,
                includingPropertiesForKeys: [.attributeModificationDateKey, .fileSizeKey],
                options: .skipsSubdirectoryDescendants) {
                // Order files based on the date
                // This map creates a tuple (url: URL, modificationDate: String, filesize: Int)
                // and then orders it by modificationDate
                let sortedURLs = directoryURLs.map { url in
                    (url: url,
                     modificationDate: (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast,
                     fileSize: (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0)
                    }
                    .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                // Now we filter GPX Files
                for (url, modificationDate, fileSize) in sortedURLs {
                    if gpxExtList.contains(url.pathExtension) {
                        GPXFiles.append(GPXFileInfo(fileURL: url))
                        let lastPathComponent = url.deletingPathExtension().lastPathComponent
                        print("fetchFileList: GPXFileInfo added \(modificationDate) \(modificationDate.timeAgo(numericDates: true)) \(fileSize)bytes -- \(lastPathComponent)")
                    }
                }
            }
        }
        print("fetchFilesList: returned \(GPXFiles.count) files")
        print("====================================================================")
        return GPXFiles
    }
}
