//
//  GPXFileTableInterfaceController.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 7/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import WatchKit
import WatchConnectivity

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
    
    private let session : WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setTitle("Your files")
        session?.delegate = self
        
        // get gpx files
        let list: [GPXFileInfo] = GPXFileManager.fileList
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjects(from: list)
            self.gpxFilesFound = true
        }
        
        loadTableData()
    }
    
    override func didAppear() {
        session?.delegate = self
        session?.activate()
    }
    
    /// Closes this view controller.
    @objc func closeGPXFilesTableViewController() {
        print("closeGPXFIlesTableViewController()")
    }
    
   
    func loadTableData() {
        fileTable.setNumberOfRows(fileList.count, withRowType: "GPXFile")
        if gpxFilesFound {
            for index in 0..<fileTable.numberOfRows {
                guard let cell = fileTable.rowController(at: index) as? GPXFileTableRowController else { continue }
                let gpxFileInfo = fileList.object(at: index) as! GPXFileInfo
                cell.fileLabel.setText(gpxFileInfo.fileName)
            }
        }
        else {
            guard let cell = fileTable.rowController(at: 0) as? GPXFileTableRowController else { return }
            cell.fileLabel.setText(kNoFiles)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let shareOption = WKAlertAction(title: "Send to iOS app", style: .default) {
            self.actionTransferFileAtIndex(rowIndex)
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
    
    
    /// Attempts to transfer file to iOS app
    func actionTransferFileAtIndex(_ rowIndex: Int) {
        session?.activate()
        guard let fileURL: URL = (fileList.object(at: rowIndex) as? GPXFileInfo)?.fileURL else {
            print("GPXFileTableViewController:: actionTransferFileAtIndex: failed to get fileURL")
            return
        }
        let gpxFileInfo = fileList.object(at: rowIndex) as! GPXFileInfo
        session?.transferFile(fileURL, metadata: ["fileName" : "/\(gpxFileInfo.fileName).gpx"])
    }
    
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


/// Handles all the file transfer to iOS app processes
extension GPXFileTableInterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("GPXFileTableInterfaceController:: activationDidCompleteWithActivationState: session activated")
        case .inactive:
             print("GPXFileTableInterfaceController:: activationDidCompleteWithActivationState: session inactive")
        case .notActivated:
            print("GPXFileTableInterfaceController:: activationDidCompleteWithActivationState: session not activated, error:\(String(describing: error))")

        default: break
        }
    }
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        let doneAction = WKAlertAction(title: "Done", style: .default) { }
        guard let error = error else {
            presentAlert(withTitle: "File Transfer", message: "GPX file successfully sent to iOS app", preferredStyle: .alert, actions: [doneAction])
            return
        }
        presentAlert(withTitle: "File Transfer", message: "GPX file was unsuccessfully sent to iOS app, error: \(error) ", preferredStyle: .alert, actions: [doneAction])
    }
    
}
