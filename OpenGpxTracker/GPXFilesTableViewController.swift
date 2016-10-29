//
//  GPXFilesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 14/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import Foundation

let kNoFiles = "No gpx files"

import UIKit
import MessageUI

class GPXFilesTableViewController: UITableViewController, UINavigationBarDelegate {
    
    var fileList: NSMutableArray = [kNoFiles]
    var gpxFilesFound = false;
    var selectedRowIndex = -1
    weak var delegate: GPXFilesTableViewControllerDelegate?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        //let navigationBar : UINavigationBar = UINavigationBar(frame: navBarFrame)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Your GPX Files"
        
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(GPXFilesTableViewController.closeGPXFilesTableViewController))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        //get gpx files
        let list: NSArray = GPXFileManager.fileList as NSArray
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjects(from: list as [AnyObject])
            self.gpxFilesFound = true
        }
    }
    
    func closeGPXFilesTableViewController() {
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
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        return fileList.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow editing for all rows except the initial "empty list"-placeholder row.
        // The string comparison is not optimal, but does the job.
        return gpxFilesFound
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            actionDeleteFileAtIndex((indexPath as NSIndexPath).row)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
        cell.textLabel?.text = fileList.object(at: (indexPath as NSIndexPath).row) as? NSString as String? ?? ""
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // self.showAlert(fileList.objectAtIndex(indexPath.row) as NSString, rowToUseInAlert: indexPath.row)
        let sheet = UIActionSheet()
        sheet.title = "Select option"
        sheet.addButton(withTitle: "Send by email")
        sheet.addButton(withTitle: "Load in Map")
        sheet.addButton(withTitle: "Cancel")
        sheet.addButton(withTitle: "Delete")
        sheet.cancelButtonIndex = 2
        sheet.destructiveButtonIndex = 3
        
        
        sheet.delegate = self
        sheet.show(in: self.view)
        self.selectedRowIndex = (indexPath as NSIndexPath).row
    }

    // MARK: UITableView delegate methods
    
    override func tableView(_ tableView: UITableView,
                            shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Allow editing for all rows except the initial "empty list"-placeholder row.
        // The string comparison is not optimal, but does the job.
        return gpxFilesFound
    }
    
    // MARK: Action Sheet - Actions
    internal func actionSheetCancel(_ actionSheet: UIActionSheet) {
        print("actionsheet cancel")
    }
    
    internal func actionDeleteFileAtIndex(_ rowIndex: Int) {
        //Delete File
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        GPXFileManager.removeFile(filename)
        //Delete from list and Table
        fileList.removeObject(at: rowIndex)
        let indexPath = IndexPath(row: rowIndex, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.reloadData()
    }
    
    internal func actionLoadFileAtIndex(_ rowIndex: Int) {
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        print("load gpx File: \(filename)")
        let fileURL: URL = GPXFileManager.URLForFilename(filename)
        let gpx = GPXParser.parseGPX(atPath: fileURL.path)
        self.delegate?.didLoadGPXFileWithName(filename, gpxRoot: gpx!)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    internal func actionSendEmailWithAttachment(_ rowIndex: Int) {
        guard let filename: String = fileList.object(at: rowIndex) as? String else {
            return
        }
        
        let fileURL: URL = GPXFileManager.URLForFilename(filename)
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        // set the subject
        composer.setSubject("[Open GPX tracker] Gpx File")
        
        //Add some text to the body and attach the file
        let body = "Open GPX Tracker \n is an open source app for Apple devices. Create GPS tracks and export them to GPX files."
        composer.setMessageBody(body, isHTML: true)
        do {
            let fileData: Data = try Data(contentsOf: URL(fileURLWithPath: fileURL.path), options: .mappedIfSafe)
            composer.addAttachmentData(fileData, mimeType:"application/gpx+xml", fileName: fileURL.lastPathComponent)
            //Display the comopser view controller
            self.present(composer, animated: true, completion: nil)
        } catch {
        }
    }
}

extension GPXFilesTableViewController: UIActionSheetDelegate{
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        print("action sheet clicked button at index \(buttonIndex)")
        switch buttonIndex {
        case 0:
            self.actionSendEmailWithAttachment(self.selectedRowIndex)
        case 1:
            self.actionLoadFileAtIndex(self.selectedRowIndex)
        case 2:
            print("ActionSheet: Cancel")
        case 3: //Delete
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
            print("Whoops")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
