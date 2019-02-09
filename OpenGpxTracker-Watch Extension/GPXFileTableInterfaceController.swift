//
//  GPXFileTableInterfaceController.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 7/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import WatchKit

/// Text displayed when there are no GPX files in the folder.
let kNoFiles = "No gpx files"

class GPXFileTableInterfaceController: WKInterfaceController {
    
    @IBOutlet var fileTable: WKInterfaceTable!
    
    /// List of strings with the filenames.
    var fileList: NSMutableArray = [kNoFiles]
    
    /// Is there any GPX file in the directory?
    var gpxFilesFound = false;
    
    /// Temporary variable to manage
    var selectedRowIndex = -1
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setTitle("Your files")
        
        // get gpx files
        let list: [GPXFileInfo] = GPXFileManager.fileList
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjects(from: list)
            self.gpxFilesFound = true
        }
        
        loadTableData()
    }
    
    /// Closes this view controller.
    @objc func closeGPXFilesTableViewController() {
        print("closeGPXFIlesTableViewController()")
    }
    
   
    func loadTableData() {
        fileTable.setNumberOfRows(fileList.count, withRowType: "GPXFile")
        
        for index in 0..<fileTable.numberOfRows {
            guard let cell = fileTable.rowController(at: index) as? GPXFileTableRowController else { continue }
            let gpxFileInfo = fileList.object(at: index) as! GPXFileInfo
            cell.fileLabel.setText(gpxFileInfo.fileName)
        }
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let shareOption = WKAlertAction(title: "Send to iOS app", style: .default) {
            
        }
        let cancelOption = WKAlertAction(title: "Cancel", style: .cancel) {
            self.actionSheetCancel()
        }
        let deleteOption = WKAlertAction(title: "Delete", style: .destructive) {
            self.actionDeleteFileAtIndex(rowIndex)
            self.loadTableData()
        }
        
        let options = [shareOption, cancelOption, deleteOption]
        
        presentAlert(withTitle: "GPX file selected", message: "What would you like to do?", preferredStyle: .actionSheet, actions: options)
    }
    
    //
    // MARK: Action Sheet - Actions
    //
    
    // Cancel button is tapped.
    //
    // Does nothing, it only displays a log message
    internal func actionSheetCancel() {
        print("ActionSheet cancel")
    }
    
    /// Deletes from the disk storage the file of `fileList` at `rowIndex`
    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        
        guard let fileURL: URL = (fileList.object(at: rowIndex) as? GPXFileInfo)?.fileURL else {
            print("GPXFileTableViewController:: actionDeleteFileAtIndex: failed to get fileURL")
            return
        }
        GPXFileManager.removeFileFromURL(fileURL)
        
        //Delete from list and Table
        fileList.removeObject(at: rowIndex)
        
    }
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
