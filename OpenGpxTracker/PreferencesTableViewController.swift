//
//  PreferencesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/10/15.
//  Copyright © 2015 TransitBox. All rights reserved.
//

import Foundation

import UIKit


class PreferencesTableViewController: UITableViewController, UINavigationBarDelegate {
    
    var selectedRowIndex = -1
    var delegate: PreferencesTableViewControllerDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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
        
        self.title = "Map Tile Server"
        
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "closePreferencesTableViewController")
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
    }
    
    func closePreferencesTableViewController() {
        print("closePreferencesTableViewController()")
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    override func viewDidAppear(animated: Bool) {
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
        return GPXTileServer.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
        //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
        let tileServer = GPXTileServer(rawValue: indexPath.row)
        cell.textLabel?.text = tileServer!.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       print("preferences: selected row at index:  \(indexPath.row)")
       self.selectedRowIndex = indexPath.row
       let defaults = NSUserDefaults.standardUserDefaults()
       defaults.setInteger(indexPath.row, forKey: "tileServerInt")
       self.delegate?.didUpdateTileServer(indexPath.row)
       self.dismissViewControllerAnimated(true, completion: nil)
 
    }
}
