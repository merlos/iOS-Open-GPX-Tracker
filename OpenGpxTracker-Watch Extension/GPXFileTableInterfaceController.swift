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
let kNoFiles = NSLocalizedString("NO_FILES", comment: "no comment")

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
    var gpxFilesFound = false
    
    /// Temporary variable to manage
    var selectedRowIndex = -1
    
    /// true if a gpx file will be sent.
    var willSendFile: Bool {
        return session?.outstandingFileTransfers.count != 0
    }
    
    /// To ensure hide animation properly timed.
    var time = DispatchTime.now()
    
    /// Watch communication session
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default: nil
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    // MARK: Progress Indicators
    
    /// States of sending files
    enum SendingStatus {
        /// represents current state as sending
        case sending
        /// represents current state as successful
        case success
        /// represents current state as failure
        case failure
    }
    
    /// Hides progress indicator's group, such that group will not appear when not needed.
    func hideProgressIndicators() {
        self.progressGroup.setHidden(true)
        self.progressImageView.stopAnimating()
        self.progressFileName.setText("")
        self.progressTitle.setText("")
    }
    
    /// Animate hiding of progress indicator's group, when needed.
    func hideProgressIndicatorsWithAnimation() {
        DispatchQueue.main.asyncAfter(deadline: time + 3) {
                self.animate(withDuration: 1, animations: {
                    self.progressGroup.setHeight(0)
                })
        }
        // imageview do not have to be set with stop animating,
        // as image indicator should already have been set as successful or failure image, which is static.
    }
    
    /// Displays progress indicators.
    ///
    /// Details like status and filename should be updated accordingly using `updateProgressIndicators(status:fileName:)`
    func showProgressIndicators() {
        self.progressGroup.setHeight(30)
        self.progressGroup.setHidden(false)
        progressImageView.setImageNamed("Progress-")
        progressImageView.startAnimatingWithImages(in: NSRange(location: 0, length: 12), duration: 1, repeatCount: 0)
    }
    
    /// Updates progress indicators according to status when sending.
    ///
    /// If status is success or failure, method will hide and animate progress indicators when done
    func updateProgressIndicators(status: SendingStatus, fileName: String?) {
        switch status {
        case .sending:
            progressTitle.setText(NSLocalizedString("SENDING", comment: "no comment"))
            guard let fileName = fileName else { return }
            
            /// count of pending files, does not seem to include the current one
            let fileTransfersCount = session?.outstandingFileTransfers.count ?? 0
            // if there are files pending for sending, filename will not be displayed with the name of file.
            if fileTransfersCount >= 1 {
                progressFileName.setText(String(format: NSLocalizedString("X_FILES", comment: "no comment"), fileTransfersCount + 1))
            } else {
                progressFileName.setText(fileName)
            }
            
        case .success:
            progressImageView.stopAnimating()
            progressImageView.setImage(UIImage(named: "Progress-success"))
            progressTitle.setText(NSLocalizedString("SUCCESSFULLY_SENT", comment: "no comment"))
            hideProgressIndicatorsWithAnimation()
            
        case .failure:
            progressImageView.stopAnimating()
            progressImageView.setImage(UIImage(named: "Progress-failure"))
            progressTitle.setText(NSLocalizedString("FAILED_TO_SEND", comment: "no comment"))
            hideProgressIndicatorsWithAnimation()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("GPXFileTableInterfaceController:: willActivate willSendFile: \(willSendFile)")
        
        self.setTitle(NSLocalizedString("YOUR_FILES", comment: "no comment"))
        session?.delegate = self
        
        if willSendFile == true {
            self.showProgressIndicators()
        } else {
            self.hideProgressIndicators()
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
    
    override func didAppear() {
        session?.delegate = self
        session?.activate()
    }
    
    override func willDisappear() {
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
                // swiftlint:disable force_cast
                let gpxFileInfo = fileList.object(at: index) as! GPXFileInfo
                cell.fileLabel.setText(gpxFileInfo.fileName)
            }
        } else {
            guard let cell = fileTable.rowController(at: 0) as? GPXFileTableRowController else { return }
            cell.fileLabel.setText(kNoFiles)
        }
    }
    
    /// Invokes when one of the cells of the table is clicked.
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        // required, if not, hide group animation will be faster than expected when display the next time.
        self.time = .now()
        
        /// checks if there is any files in directory
        if gpxFilesFound {
            
            /// Option lets user send selected file to iOS app
            let shareOption = WKAlertAction(title: NSLocalizedString("SEND_TO_IOS", comment: "no comment"), style: .default) {
                self.actionTransferFileAtIndex(rowIndex)
            }
            
            /// Option for users to cancel
            let cancelOption = WKAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"), style: .cancel) {
                self.actionSheetCancel()
            }
            
            /// Option to delete selected file
            let deleteOption = WKAlertAction(title: NSLocalizedString("DELETE", comment: "no comment"), style: .destructive) {
                self.actionDeleteFileAtIndex(rowIndex)
                self.loadTableData()
            }
            
            /// Array of all available options
            let options = [shareOption, cancelOption, deleteOption]
            
            presentAlert(withTitle: NSLocalizedString("FILE_SELECTED_TITLE", comment: "no comment"),
                         message: NSLocalizedString("FILE_SELECTED_MESSAGE", comment: "no comment"),
                         preferredStyle: .actionSheet, actions: options)
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
            self.hideProgressIndicators()
            return
        }
        // swiftlint:disable force_cast
        let gpxFileInfo = fileList.object(at: rowIndex) as! GPXFileInfo
        self.scroll(to: progressGroup, at: .top, animated: true) // scrolls to top when indicator is shown.
        self.updateProgressIndicators(status: .sending, fileName: gpxFileInfo.fileName)
        DispatchQueue.global().async {
            self.session?.transferFile(fileURL, metadata: ["fileName": "\(gpxFileInfo.fileName).gpx"])
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

// MARK: WCSessionDelegate

///
/// Handles all the file transfer to iOS app processes
///
extension GPXFileTableInterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let prefixText = "GPXFileTableInterfaceController:: activationDidCompleteWithActivationState:"
        switch activationState {
        case .activated:
            print("\(prefixText) session activated")
        case .inactive:
            print("\(prefixText) session inactive")
        case .notActivated:
            print("\(prefixText) session not activated, error:\(String(describing: error))")

        default:
            print("\(prefixText) default, error:\(String(describing: error))")
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        let doneAction = WKAlertAction(title: NSLocalizedString("DONE", comment: "no comment"), style: .default) { }
        guard let error = error else {
            print("WCSession: didFinish fileTransfer: \(fileTransfer.file.fileURL.absoluteString)")
            // presenting success indicator to user if file is successfully transferred
            // will only present once all files are sent (if multiple in queue)
            if session.outstandingFileTransfers.count == 1 {
                self.updateProgressIndicators(status: .success, fileName: nil)
            }
            return
        }
        
        // presents indicator first, if file transfer failed, without error message
        self.updateProgressIndicators(status: .failure, fileName: nil)
        
        // presents alert after 1.5s, with error message
        // MARK: "as CVarArg" was suggested by XCode and my intruduce a bug...
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.presentAlert(withTitle: NSLocalizedString("ERROR_OCCURED_TITLE", comment: "no comment"),
                              message: String(format: NSLocalizedString("ERROR_OCCURED_MESSAGE", comment: "no comment"), error as CVarArg),
                              preferredStyle: .alert, actions: [doneAction])
        }
    }
    
}
