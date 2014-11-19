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
    
    class var gpxFilesFolder: String {
        get {
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            return documentsDirectory
        }
    }
    //Gets the list of .gpx files in Documents directory
    class var fileList: [AnyObject]  {
        get {
            let defaultManager = NSFileManager.defaultManager()
            var filePathsArray : NSArray = defaultManager.subpathsOfDirectoryAtPath(self.gpxFilesFolder, error: nil)!
            let predicate : NSPredicate = NSPredicate(format: "SELF EndsWith '.\(kFileExt)'")!
            filePathsArray = filePathsArray.filteredArrayUsingPredicate(predicate)
            
            //We want latest files created on top. It seems we have to reverse the path
            filePathsArray = filePathsArray.reverseObjectEnumerator().allObjects
            return filePathsArray
        }
    }
    //
    // @param filename gpx filename without extension
    class func pathForFilename(filename: String) -> String {
        let documentsPath = self.gpxFilesFolder
        var ext = ".\(kFileExt)" // add dot to file extension
        //check if extension is already there
        let tmpExt : String = filename.pathExtension
        println("extension: \(tmpExt)")
        if kFileExt ==  tmpExt  {
            ext = ""
        }
        let fullPath = documentsPath.stringByAppendingPathComponent("\(filename)\(ext)")
        return fullPath
    }
    class func fileExists(filename: String) -> Bool {
        let filePath = self.pathForFilename(filename)
        return NSFileManager.defaultManager().fileExistsAtPath(filePath);
    }
    
    class func save(filename: String, gpxContents : String) {
        //check if name exists
        var finalFilename = filename
        var i = 2
        while self.fileExists(finalFilename) {
            finalFilename = filename + " (\(i))"
        }
        let finalFilePath: String = self.pathForFilename(finalFilename)
        //save file
        println("Saving file at path: \(finalFilePath)")
        // write gpx to file
        

        var writeError: NSError?
        let saved: Bool = gpxContents.writeToFile(finalFilePath, atomically: true, encoding: NSUTF8StringEncoding, error: &writeError)
        if !saved {
            if let error = writeError {
                println("[ERROR] GPXFileManager:save: \(error.localizedDescription)")
            }
        }
    }
    
    class func removeFile(filename: String) {
        let filepath: String = self.pathForFilename(filename)
        let defaultManager = NSFileManager.defaultManager()
        var error: NSError?
        let deleted: Bool = defaultManager.removeItemAtPath(filepath, error: &error)
        if !deleted {
             if let e = error {
                println("[ERROR] GPXFileManager:removeFile: \(filepath) : \(e.localizedDescription)")
            }
        }
    }
    
}