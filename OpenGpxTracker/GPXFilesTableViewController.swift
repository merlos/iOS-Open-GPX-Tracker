//
//  GPXFilesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 14/09/14.
//

import Foundation
import UIKit
import MessageUI

/// Text displayed when there are no GPX files in the folder.
let kNoFiles = "No gpx files"

///
/// TableViewController that displays the list of files that have been saved in previous sessions.
///
/// This view controller allows users to manage their GPX Files.
///
/// Currently the following actions with a file are supported
///
/// 1. Send it by email
/// 2. Load in the map
/// 3. Delete the file
///
/// It also displays a button "Done" in the navigation bar to return to the map.
///
class GPXFilesTableViewController: UITableViewController, UINavigationBarDelegate {
   
    /// List of strings with the filenames.
    var fileList: NSMutableArray = [kNoFiles]
    
    /// Is there any GPX file in the directory?
    var gpxFilesFound = false;
    
    /// Temporary variable to manage
    var selectedRowIndex = -1
    
    ///
    weak var delegate: GPXFilesTableViewControllerDelegate?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    ///
    /// Setups the view controller.
    ///
    /// 1. Sets the title
    /// 2. Adds the "Done" button
    /// 3. Loads existing GPX File list.
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Your GPX Files"
        
        // Button to return to the map
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        // Get gpx files
        let list: [GPXFileInfo] = GPXFileManager.fileList
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjects(from: list)
            self.gpxFilesFound = true
        }
    }
    
    /// Closes this view controller.
    @objc func closeGPXFilesTableViewController() {
        print("closeGPXFIlesTableViewController()")
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    
    /// Returns the number of files in the section.
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    /// Allow edit rows? Returns true only if there are files.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return gpxFilesFound
    }
    
    /// Displays the delete button.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    /// Displays the name of the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        tableView.register(UINib(nibName: "GPXFilesTableViewCell", bundle: nil), forCellReuseIdentifier: "newCell")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! GPXFilesTableViewCell
        
        if gpxFilesFound {
            //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
            //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
            let gpxFileInfo = fileList.object(at: (indexPath as NSIndexPath).row) as! GPXFileInfo
            
            cell.nameLabel.text = gpxFileInfo.fileName
            cell.lastModifiedLabel.text = "last saved \(gpxFileInfo.modifiedDatetimeAgo) (\(gpxFileInfo.fileSizeHumanised))"
            cell.lastModifiedLabel.textColor = .darkGray
            cell.distanceLabel.textColor = .darkGray
            
            if gpxFileInfo.fileDistance > 1000.0 { //use km
                let formatted = String(format: "%.2f", (gpxFileInfo.fileDistance/1000.0))
                cell.distanceLabel.text = "\(formatted)km"
            } else {
                let formatted = String(format: "%.0f", (gpxFileInfo.fileDistance))
                cell.distanceLabel.text = "\(formatted)m"
            }
            //cell.textLabel?.text = gpxFileInfo.fileName
            //cell.detailTextLabel?.text =
            //  "last saved \(gpxFileInfo.modifiedDatetimeAgo) (\(gpxFileInfo.fileSizeHumanised))"
            //cell.detailTextLabel?.textColor = UIColor.darkGray
        } else {
            cell.nameLabel?.text = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        }
        
        return cell

    }
    
    /// Displays an action sheet with the actions for that file (Send it by email, Load in map and Delete)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let sheet = UIActionSheet()
        sheet.title = "Select option"
        sheet.addButton(withTitle: "Send by email")
        sheet.addButton(withTitle: "Load in Map")
        sheet.addButton(withTitle: "Share")
        sheet.addButton(withTitle: "Cancel")
        sheet.addButton(withTitle: "Delete")
        sheet.cancelButtonIndex = 3
        sheet.destructiveButtonIndex = 4

        sheet.delegate = self
        sheet.show(in: self.view)
        self.selectedRowIndex = (indexPath as NSIndexPath).row
    }

    // MARK: UITableView delegate methods
    
    /// Only highlight rows if there are files.
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return gpxFilesFound
    }
    
    internal func fileListObjectTitle(_ rowIndex: Int) -> String {
        return (fileList.object(at: rowIndex) as! GPXFileInfo).fileName
    }
    
    // MARK: Action Sheet - Actions
    
    internal func actionSheetCancel(_ actionSheet: UIActionSheet) {
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
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        tableView.reloadData()
    }
    
    /// Loads the GPX file that corresponds to rowIndex in fileList in the map.
    internal func actionLoadFileAtIndex(_ rowIndex: Int) {
        guard let gpxFileInfo: GPXFileInfo = (fileList.object(at: rowIndex) as? GPXFileInfo) else {
            print("GPXFileTableViewController:: actionLoadFileAtIndex(\(rowIndex)): failed to get fileURL")
            return
        }
        
        print("Load gpx File: \(gpxFileInfo.fileName)")
        let gpx = GPXParser.parseGPX(atPath: gpxFileInfo.fileURL.path)
        self.delegate?.didLoadGPXFileWithName(gpxFileInfo.fileName, gpxRoot: gpx!)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    /// Shares file at `rowIndex`
    internal func actionShareFileAtIndex(_ rowIndex: Int) {
        guard let gpxFileInfo: GPXFileInfo = (fileList.object(at: rowIndex) as? GPXFileInfo) else {
            print("Unable to get filename at row \(rowIndex), cannot respond to \(type(of: self))didSelectRowAt")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [gpxFileInfo.fileURL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    /// Sends the file at `rowIndex` by email
    internal func actionSendEmailWithAttachment(_ rowIndex: Int) {
        guard let gpxFileInfo: GPXFileInfo = (fileList.object(at: rowIndex) as? GPXFileInfo) else {
            return
        }
        let fileURL: URL = gpxFileInfo.fileURL
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        // set the subject
        composer.setSubject("[Open GPX tracker] Share file \(gpxFileInfo.fileName).gpx")
        //Add some text to the body and attach the file
        let body = "File sent with Open GPX Tracker for iOS. Create GPS tracks and share them as GPX files."
        composer.setMessageBody(body, isHTML: true)
        do {
            let fileData: Data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            composer.addAttachmentData(fileData, mimeType:"application/gpx+xml", fileName: fileURL.lastPathComponent)
            //Display the comopser view controller
            self.present(composer, animated: true, completion: nil)
        } catch {
            print("Error while composing email")
        }
    }
}

/// Handles what to do when user touches one of the options of the action sheet
extension GPXFilesTableViewController: UIActionSheetDelegate{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        print("action sheet clicked button at index \(buttonIndex)")
        switch buttonIndex {
        case 0:
            self.actionSendEmailWithAttachment(self.selectedRowIndex)
        case 1:
            self.actionLoadFileAtIndex(self.selectedRowIndex)
        case 2:
            self.actionShareFileAtIndex(self.selectedRowIndex)
        case 3:
            print("ActionSheet: Cancel")
        case 4: //Delete
            self.actionDeleteFileAtIndex(self.selectedRowIndex)
        default: //cancel
            print("action Sheet do nothing")
        }
    }
}

extension GPXFilesTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result.rawValue {
        case MFMailComposeResult.sent.rawValue:
            print("Email sent")
            
        default:
            print("Whoops email was not sent :-(")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
