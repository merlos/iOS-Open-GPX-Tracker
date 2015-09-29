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
class GPXFileManager : NSObject {
    
    class var GPXFilesFolderURL: NSURL {
        get {
            let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
            return documentsUrl
        }
    }
    //Gets the list of .gpx files in Documents directory
    class var fileList: [AnyObject]  {
        get {
            var GPXFiles:[String] = []
            let fileManager = NSFileManager.defaultManager()
            // We need just to get the documents folder url
                let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
                
                do {
                    // if you want to filter the directory contents you can do like this:
                    if let directoryURLs = try? NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsURL, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants) {
                        print(directoryURLs)
                        for url:NSURL in directoryURLs {
                            if url.pathExtension == kFileExt {
                                GPXFiles.append(url.URLByDeletingPathExtension!.lastPathComponent!)
                            }
                        }
                    }//if
                }
            return GPXFiles
        }
    }
    //
    // @param filename gpx filename without extension
    class func URLForFilename(filename: String) -> NSURL {
        var fullURL = self.GPXFilesFolderURL.URLByAppendingPathComponent(filename)
        //var ext = ".\(kFileExt)" // add dot to file extension
        print("pathForFilename: \(fullURL)")
        //check if filename has extension
        if fullURL.pathExtension != kFileExt {
            print("oh! is not a gpx file");
            fullURL = fullURL.URLByAppendingPathExtension(kFileExt)
        }
        return fullURL
    }
    
    class func fileExists(filename: String) -> Bool {
        let fileURL = self.URLForFilename(filename)
        return NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!)
    }
    
    class func save(filename: String, gpxContents : String) {
        //check if name exists
        let finalFileURL: NSURL = self.URLForFilename(filename)
        //save file
        print("Saving file at path: \(finalFileURL)")
        // write gpx to file
        var writeError: NSError?
        let saved: Bool
        do {
            try gpxContents.writeToFile(finalFileURL.path!, atomically: true, encoding: NSUTF8StringEncoding)
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
    
    class func removeFile(filename: String) {
        let fileURL: NSURL = self.URLForFilename(filename)
        let defaultManager = NSFileManager.defaultManager()
        var error: NSError?
        let deleted: Bool
        do {
            try defaultManager.removeItemAtPath(fileURL.path!)
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