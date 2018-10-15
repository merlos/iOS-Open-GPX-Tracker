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
        if gpxFilesFound {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
            //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
            let gpxFileInfo = fileList.object(at: (indexPath as NSIndexPath).row) as! GPXFileInfo
            cell.textLabel?.text = gpxFileInfo.fileName
            cell.detailTextLabel?.text =
                "last saved \(gpxFileInfo.modifiedDatetimeAgo) (\(gpxFileInfo.fileSizeHumanised))"
            cell.detailTextLabel?.textColor = UIColor.darkGray
            return cell
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
            cell.textLabel?.text = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
            return cell
        }
    }
    
    
    /// Displays an action sheet with the actions for that file (Send it by email, Load in map and Delete)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let sheet = UIAlertController(title: nil, message: "Select option", preferredStyle: .actionSheet)
        let mapOption = UIAlertAction(title: "Load in Map", style: .default) { action in
            self.actionLoadFileAtIndex(indexPath.row)
        }
        let shareOption = UIAlertAction(title: "Share", style: .default) { action in
            self.actionShareFileAtIndex(indexPath.row, tableView: tableView, indexPath: indexPath)
        }
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.actionSheetCancel(sheet)
        }
        
        let deleteOption = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.actionDeleteFileAtIndex(indexPath.row)
        }
        
        sheet.addAction(mapOption)
        sheet.addAction(shareOption)
        sheet.addAction(cancelOption)
        sheet.addAction(deleteOption)
        sheet.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        sheet.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
        
        self.present(sheet, animated: true) {
            print("Loaded actionSheet")
        }
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
    
    //
    // MARK: Action Sheet - Actions
    //
    
    // Cancel button is taped.
    //
    // Does nothing, it only displays a log message
    internal func actionSheetCancel(_ actionSheet: UIAlertController) {
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
    internal func actionShareFileAtIndex(_ rowIndex: Int, tableView: UITableView, indexPath: IndexPath) {
        guard let gpxFileInfo: GPXFileInfo = (fileList.object(at: rowIndex) as? GPXFileInfo) else {
            print("Unable to get filename at row \(rowIndex), cannot respond to \(type(of: self))didSelectRowAt")
            return
        }
        print("GPXTableViewController: actionShareFileAtIndex")
        
        let activityViewController = UIActivityViewController(activityItems: [gpxFileInfo.fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
        activityViewController.popoverPresentationController?.sourceRect = (tableView.cellForRow(at: indexPath)?.frame)!
        activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                print("actionShareAtIndex: Cancelled")
                return
            }
            // User completed activity
            print("actionShareFileAtIndex: User completed activity")
        }
        self.present(activityViewController, animated: true, completion: nil)
    }
}
