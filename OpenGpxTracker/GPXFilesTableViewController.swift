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

class GPXFilesTableViewController : UITableViewController, UINavigationBarDelegate {
    
    var fileList:NSMutableArray = [kNoFiles]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder)  {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        //let navigationBar : UINavigationBar = UINavigationBar(frame: navBarFrame)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Your GPX Files"
        
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: "closeGPXFilesTableViewController")
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        //get gpx files
        /*let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

        let defaultManager = NSFileManager.defaultManager()
        var filePathsArray : NSArray = defaultManager.subpathsOfDirectoryAtPath(documentsDirectory, error: nil)!
        let predicate : NSPredicate = NSPredicate(format: "SELF EndsWith '.gpx'")
        filePathsArray = filePathsArray.filteredArrayUsingPredicate(predicate)
        
        println(filePathsArray)
        */
        let list: NSArray = GPXFileManager.fileList
        if list.count != 0 {
            self.fileList.removeAllObjects()
            self.fileList.addObjectsFromArray(list)
        }
    }
    
    func closeGPXFilesTableViewController() {
        println("closeGPXFIlesTableViewController()")
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
            //Delete File
            let filename: String = fileList.objectAtIndex(indexPath.row) as String
            GPXFileManager.removeFile(filename)
            //Delete from list and Table
            fileList.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
            cell.textLabel?.text = fileList.objectAtIndex(indexPath.row) as NSString
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.showAlert(fileList.objectAtIndex(indexPath.row) as NSString, rowToUseInAlert: indexPath.row)
    }
    
    //#pragma mark - UIAlertView delegate methods
    
    func alertView(alertView: UIAlertView!, didDismissWithButtonIndex buttonIndex: Int) {
        NSLog("Did dismiss button: %d", buttonIndex)
    }
    
    // Function to init a UIAlertView and show it
    func showAlert(rowTitle:NSString, rowToUseInAlert: Int) {
        var alert = UIAlertView()
        
        alert.delegate = self
        alert.title = rowTitle
        alert.message = "You selected row \(rowToUseInAlert)"
        alert.addButtonWithTitle("OK")
        
        alert.show()
    }
}
