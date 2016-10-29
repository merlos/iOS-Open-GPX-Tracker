//
//  GPXFileManager.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation

//GPX File extension
let kFileExt = "gpx"

//
// Class to handle actions with gpx files (save, delete, etc..)
//
//
class GPXFileManager: NSObject {
    
    class var GPXFilesFolderURL: URL {
        get {
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            return documentsUrl
        }
    }
    //Gets the list of .gpx files in Documents directory
    class var fileList: [AnyObject] {
        get {
            var GPXFiles: [String] = []
            let fileManager = FileManager.default
            // We need just to get the documents folder url
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
                
                do {
                    // if you want to filter the directory contents you can do like this:
                    if let directoryURLs = try? FileManager.default.contentsOfDirectory(at: documentsURL,
                        includingPropertiesForKeys: nil,
                        options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants) {
                            
                        print(directoryURLs)
                        for url: URL in directoryURLs {
                            if url.pathExtension == kFileExt {
                                GPXFiles.append(url.deletingPathExtension().lastPathComponent)
                            }
                        }
                    }//if
                }
            return GPXFiles as [AnyObject]
        }
    }
    //
    // @param filename gpx filename without extension
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
    
    class func fileExists(_ filename: String) -> Bool {
        let fileURL = self.URLForFilename(filename)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    class func save(_ filename: String, gpxContents: String) {
        //check if name exists
        let finalFileURL: URL = self.URLForFilename(filename)
        //save file
        print("Saving file at path: \(finalFileURL)")
        // write gpx to file
        var writeError: NSError?
        let saved: Bool
        do {
            try gpxContents.write(toFile: finalFileURL.path, atomically: true, encoding: String.Encoding.utf8)
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
    
    class func removeFile(_ filename: String) {
        let fileURL: URL = self.URLForFilename(filename)
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
}
