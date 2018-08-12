//
//  GPXLoadFileDelegate.swift
//  OpenGpxTracker
//
//  Created by merlos on 23/09/14.
//

import Foundation

//
// Delegate protocol of the view controller that displays the list of files
//
//
protocol GPXFilesTableViewControllerDelegate: class {
  
    //GPXFilesTableView controller will be dismissed after calling this method
    //gpxFile is the name without extension
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot)
    
}
