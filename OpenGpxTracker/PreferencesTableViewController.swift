//
//  PreferencesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/10/15.
//  Copyright © 2015 TransitBox. All rights reserved.
//

import Foundation

import UIKit
import Cache

//Sections
let kCacheSection = 0
let kMapSourceSection = 1

//CacheSection Cells
let kUseOfflineCacheCell = 0
let kClearCacheCell = 1



let kDefaultsKeyTileServerInt: String = "TileServerInt"
let kDefaultsKeyUseCache: String = "UseCache"


//
// There are two preferences available:
//  * use or not cache
//  * select the map source (tile server)
//
// Preferences are kept on UserDefaults with the keys kDefaultKeyTileServerInt (Int)  and kDefaultUseCache (Bool)
//
class PreferencesTableViewController: UITableViewController, UINavigationBarDelegate {
    
    var selectedTileServerInt = -1
    var currentUseCache: Bool = true
    let defaults = UserDefaults.standard
    weak var delegate: PreferencesTableViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        //let navigationBar : UINavigationBar = UINavigationBar(frame: navBarFrame)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Preferences"
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(PreferencesTableViewController.closePreferencesTableViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        //Load preferences from defaults
        selectedTileServerInt = defaults.integer(forKey: kDefaultsKeyTileServerInt)
        if let useCacheFromDefaults = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            print("PreferencesTableViewController:: loaded preference useCache= \(useCacheFromDefaults)");
            self.currentUseCache = useCacheFromDefaults
        }
    }
    
    func closePreferencesTableViewController() {
        print("closePreferencesTableViewController()")
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
    
    //#pragma mark - Table view data source
    
    override func numberOfSections(in tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 2
    }
    
    // Customize the section headings for each section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case kCacheSection: return "Cache"
        case kMapSourceSection: return "Map source"
        default: fatalError("Unknown section")
        }
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section.
        switch(section) {
        case kCacheSection: return 2
        case kMapSourceSection: return GPXTileServer.count
        default: fatalError("Unknown section")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "MapCell")
        
        if indexPath.section == kCacheSection {
            switch (indexPath.row) {
            case kUseOfflineCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Offline cache"
                if currentUseCache {
                    cell.accessoryType = .checkmark
                }
            case kClearCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Clear cache"
                cell.textLabel?.textColor = UIColor.red
            default: fatalError("Unknown section")
            }
        }
        if indexPath.section == kMapSourceSection {
            //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
            //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
            let tileServer = GPXTileServer(rawValue: indexPath.row)
            cell.textLabel?.text = tileServer!.name
            if indexPath.row == self.selectedTileServerInt {
                cell.accessoryType = .checkmark
            }
            
            return cell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        
        //section 0 (Cache)
        if indexPath.section == 0 {  // 0 -> sets and unsets cache
            switch indexPath.row {
            case kCacheSection:
                print("toggle cache")
                let newUseCache = !self.currentUseCache //toggle value
                defaults.set(newUseCache, forKey: kDefaultsKeyUseCache)
                self.currentUseCache = newUseCache
                //update cell
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseCache ? .checkmark : .none
                //notify the map
                self.delegate?.didUpdateUseCache(newUseCache)
            case 1:
                print("clear cache")
                // 1 -> clears cache
                let cache = Cache<Data>(name: "ImageCache")
                cache.clear()
                let cell = tableView.cellForRow(at: indexPath)!
                cell.textLabel?.text = "Cache is now empty"
                cell.textLabel?.textColor = UIColor.gray
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        } else { // section 1 (sets tileServerInt in defaults
            print("PreferenccesTableView Map Tile Server section Row at index:  \(indexPath.row)")
            //remove checkmark from selected tile server
            let selectedTileServerIndexPath = IndexPath(row: self.selectedTileServerInt, section: indexPath.section)
            tableView.cellForRow(at: selectedTileServerIndexPath)?.accessoryType = .none
            
            //add checkmark to new tile server
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            self.selectedTileServerInt = indexPath.row
            
            //save preference
            defaults.set(indexPath.row, forKey: kDefaultsKeyTileServerInt)
            
            //update map
            self.delegate?.didUpdateTileServer((indexPath as NSIndexPath).row)
            //self.dismiss(animated: true, completion: nil)
        }
        //unselect row
        tableView.deselectRow(at: indexPath, animated: true)
        
     
    }
}
