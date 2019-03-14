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

///
/// WKInterfaceTable that displays the list of files that have been saved in previous sessions.
///
/// This interface controller allows users to manage their GPX Files.
///
/// Currently the following actions with a file are supported
///
/// 1. Send file to iOS App
/// 3. Delete the file
///
/// It also displays a back button to return to the main controls view.
///
class GPXFileTableInterfaceController: WKInterfaceController {
    
    /// Main table that displays list of files
    @IBOutlet var fileTable: WKInterfaceTable!
    @IBOutlet var progressGroup: WKInterfaceGroup!
    @IBOutlet var progressTitle: WKInterfaceLabel!
    @IBOutlet var progressFileName: WKInterfaceLabel!
    @IBOutlet var progressImageView: WKInterfaceImage!
    
    /// List of strings with the filenames.
    var fileList: NSMutableArray = [kNoFiles]
    
    /// Is there any GPX file in the directory?
    var gpxFilesFound = false;
    
    /// Temporary variable to manage
    var selectedRowIndex = -1
    
    var willSendFile = false
    
    /// Watch communication session
    private let session : WCSession? = WCSession.isSupported() ? WCSession.default : nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    // MARK:- Progress Indicator
    
    enum sendingStatus {
        case Sending, Success, Failure
    }
    
    func hideProgressControls() {
        //self.progressGroup.setAlpha(0)
        self.progressGroup.setHidden(true)
        self.progressImageView.stopAnimating()
    }
    
    func hideProgressControlsWithAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.animate(withDuration: 1, animations: {
                    self.progressGroup.setHeight(0)
                })
        }
    }
    
    func showProgressControls() {
        self.progressGroup.setHeight(30)
        self.progressGroup.setHidden(false)
        progressImageView.setImageNamed("Progress-")
        progressImageView.startAnimatingWithImages(in: NSMakeRange(0, 12), duration: 1, repeatCount: 0)
    }
    
    func updateProgressControlsText(status: sendingStatus, fileName: String?) {
        switch status {
        case .Sending:
            progressTitle.setText("Sending:")
            guard let fileName = fileName else { return }
            let fileTransfersCount = session?.outstandingFileTransfers.count ?? 0
            if  fileTransfersCount > 1 {
                progressFileName.setText("\(fileTransfersCount) files")
            }
            else {
                progressFileName.setText(fileName)
            }
        case .Success:
            progressImageView.stopAnimating()
            progressImageView.setImage(UIImage(named: "Progress-success"))
            progressTitle.setText("Sucessfully sent:")
            hideProgressControlsWithAnimation()
        case .Failure:
            progressImageView.stopAnimating()
            progressImageView.setImage(UIImage(named: "Progress-failure"))
            progressTitle.setText("Failed to send:")
            hideProgressControlsWithAnimation()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setTitle("Your files")
        session?.delegate = self
        
        if willSendFile == true {
            self.showProgressControls()
        }
        else {
            self.hideProgressControls()
        }
        
        // get gpx files
        let list: [GPXFileInfo] = GPXFileManager.fileList
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjects(from: list)
            self.gpxFilesFound = true
        }
        
        loadTableData()
    }
    override func willDisappear() {
        willSendFile = false
    }
    override func didAppear() {
        session?.delegate = self
        session?.activate()
    }
    
    /// Closes this view controller.
    @objc func closeGPXFilesTableViewController() {
        print("closeGPXFIlesTableViewController()")
    }
    
    /// Loads data on the table
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
    
    /// Invokes when one of the cells of the table is clicked.
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        /// checks if there is any files in directory
        if gpxFilesFound {
            
            /// Option lets user send selected file to iOS app
            let shareOption = WKAlertAction(title: "Send to iOS app", style: .default) {
                self.willSendFile = true
                self.actionTransferFileAtIndex(rowIndex)
            }
            
            /// Option for users to cancel
            let cancelOption = WKAlertAction(title: "Cancel", style: .cancel) {
                self.willSendFile = false
                self.actionSheetCancel()
            }
            
            /// Option to delete selected file
            let deleteOption = WKAlertAction(title: "Delete", style: .destructive) {
                self.willSendFile = false
                self.actionDeleteFileAtIndex(rowIndex)
                self.loadTableData()
            }
            
            /// Array of all available options
            let options = [shareOption, cancelOption, deleteOption]
            
            presentAlert(withTitle: "GPX file selected", message: "What would you like to do?", preferredStyle: .actionSheet, actions: options)
        }
    }
    
    //
    // MARK: Action Sheet - Actions
    //
    
    
    /// Attempts to transfer file to iOS app
    func actionTransferFileAtIndex(_ rowIndex: Int) {
        session?.activate()
        guard let fileURL: URL = (fileList.object(at: rowIndex) as? GPXFileInfo)?.fileURL else {
            print("GPXFileTableViewController:: actionTransferFileAtIndex: failed to get fileURL")
            self.hideProgressControls()
            return
        }
        let gpxFileInfo = fileList.object(at: rowIndex) as! GPXFileInfo
        self.updateProgressControlsText(status: .Sending, fileName: gpxFileInfo.fileName)
        DispatchQueue.global().async {
            self.session?.transferFile(fileURL, metadata: ["fileName" : "\(gpxFileInfo.fileName).gpx"])
        }
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

///
/// MARK:- WCSessionDelegate
///
/// Handles all the file transfer to iOS app processes
///
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
            
            // presenting alert to user if file is successfully transferred
            //presentAlert(withTitle: "File Transfer", message: "GPX file successfully sent to iOS app", preferredStyle: .alert, actions: [doneAction])
            if session.outstandingFileTransfers.count == 1 {
                self.updateProgressControlsText(status: .Success, fileName: nil)
            }
            return
        }
        
        // presenting alert if file transfer failed, including error message
        self.updateProgressControlsText(status: .Failure, fileName: nil)
        presentAlert(withTitle: "File Transfer", message: "GPX file was unsuccessfully sent to iOS app, error: \(error) ", preferredStyle: .alert, actions: [doneAction])
    }
    
}
