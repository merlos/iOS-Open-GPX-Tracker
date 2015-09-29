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

class GPXFilesTableViewController : UITableViewController, UINavigationBarDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate  {
    
    var fileList:NSMutableArray = [kNoFiles]
    var selectedRowIndex = -1
    var delegate: GPXFilesTableViewControllerDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        //let navigationBar : UINavigationBar = UINavigationBar(frame: navBarFrame)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Your GPX Files"
        
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "closeGPXFilesTableViewController")
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        //get gpx files
        let list: NSArray = GPXFileManager.fileList
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjectsFromArray(list as [AnyObject])
        }
    }
    
    func closeGPXFilesTableViewController() {
        print("closeGPXFIlesTableViewController()")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    override func viewDidAppear(animated: Bool)
    {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //#pragma mark - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        return fileList.count;
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true;
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if(editingStyle == UITableViewCellEditingStyle.Delete)
        {
            actionDeleteFileAtIndex(indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
        cell.textLabel?.text = fileList.objectAtIndex(indexPath.row) as! NSString as String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
       // self.showAlert(fileList.objectAtIndex(indexPath.row) as NSString, rowToUseInAlert: indexPath.row)
        let sheet = UIActionSheet()
        sheet.title = "Select option"
        sheet.addButtonWithTitle("Send by email")
        sheet.addButtonWithTitle("Load in Map")
        sheet.addButtonWithTitle("Cancel")
        sheet.addButtonWithTitle("Delete")
        sheet.cancelButtonIndex = 2
        sheet.destructiveButtonIndex = 3
        
        
        sheet.delegate = self
        sheet.showInView(self.view)
        self.selectedRowIndex = indexPath.row
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
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
    func actionSheetCancel(actionSheet: UIActionSheet) {
        print("actionsheet cancel")
    }
    
    //#pragma mark - UIAlertView delegate methods
    
    func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int) {
        NSLog("Did dismiss button: %d", buttonIndex)
    }
    
    func actionDeleteFileAtIndex(rowIndex: Int) {
        //Delete File
        let filename: String = fileList.objectAtIndex(rowIndex) as! String
        GPXFileManager.removeFile(filename)
        //Delete from list and Table
        fileList.removeObjectAtIndex(rowIndex)
        let indexPath = NSIndexPath(forRow: rowIndex, inSection: 0)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        tableView.reloadData()
    }
    
    func actionLoadFileAtIndex(rowIndex: Int) {
        let filename: String = fileList.objectAtIndex(rowIndex) as! String
        print("load gpx File: \(filename)")
        let fileURL: NSURL = GPXFileManager.URLForFilename(filename)
        let gpx = GPXParser.parseGPXAtPath(fileURL.path)
        self.delegate?.didLoadGPXFileWithName(filename, gpxRoot: gpx)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    //#pragma mark - Send email
    func actionSendEmailWithAttachment(rowIndex: Int) {
        let filename: String = fileList.objectAtIndex(rowIndex) as! String
        let fileURL: NSURL = GPXFileManager.URLForFilename(filename)
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        
        // set the subject
        composer.setSubject("[Open GPX tracker] Gpx File")
        
        //Add some text to the body and attach the file
        let body = "Open GPX Tracker \n is an open source app for Apple devices. Create GPS tracks and export them to GPX files."
        composer.setMessageBody(body, isHTML: true)
        let fileData: NSData = try! NSData(contentsOfFile: fileURL.path!, options: .DataReadingMappedIfSafe)
        composer.addAttachmentData(fileData, mimeType:"application/gpx+xml", fileName: fileURL.lastPathComponent!)
        
        //Display the comopser view controller
        self.presentViewController(composer, animated: true, completion: nil)

    }
    


    func mailComposeController(controller: MFMailComposeViewController,
        didFinishWithResult result: MFMailComposeResult,
        error: NSError?){
            
            switch(result.rawValue){
            case MFMailComposeResultSent.rawValue:
                print("Email sent")
                
            default:
                print("Whoops")
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            
    }
}
