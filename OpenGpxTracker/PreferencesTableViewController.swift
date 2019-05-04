//
//  PreferencesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/10/15.
//

import Foundation
import UIKit

import Cache

/// Units Section Id in PreferencesTableViewController
let kUnitsSection = 0

/// Cache Section Id in PreferencesTableViewController
let kCacheSection = 1

/// Map Source Section Id in PreferencesTableViewController
let kMapSourceSection = 2

// Cell Id of the Use Imperial units in UnitsSection
let kUseImperialUnitsCell = 0

/// Cell Id for Use offline cache in CacheSection of PreferencesTableViewController
let kUseOfflineCacheCell = 0

/// Cell Id for Clear cache in CacheSection of PreferencesTableViewController
let kClearCacheCell = 1

///
/// There are two preferences available:
///  * use or not cache
///  * select the map source (tile server)
///
/// Preferences are kept on UserDefaults with the keys `kDefaultKeyTileServerInt` (Int)
/// and `kDefaultUseCache`` (Bool)
///
class PreferencesTableViewController: UITableViewController, UINavigationBarDelegate {
    
    /// Delegate for this table view controller.
    weak var delegate: PreferencesTableViewControllerDelegate?
    
    /// Global Preferences
    var preferences : Preferences = Preferences.shared
    
    /// Does the following:
    /// 1. Defines the areas for navBar and the Table view
    /// 2. Sets the title
    /// 3. Loads the Preferences from defaults
    override func viewDidLoad() {
        super.viewDidLoad()
        let navBarFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 64)
        //let navigationBar : UINavigationBar = UINavigationBar(frame: navBarFrame)
        self.tableView.frame = CGRect(x: navBarFrame.width + 1, y: 0, width: self.view.frame.width, height:
            self.view.frame.height - navBarFrame.height)
        
        self.title = "Preferences"
        let shareItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PreferencesTableViewController.closePreferencesTableViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
    }
    
    /// Close this controller.
    @objc func closePreferencesTableViewController() {
        print("closePreferencesTableViewController()")
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    /// Loads data
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    /// Does nothing for now.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    /// Returns 3 sections: Units, Cache, Map Source
    override func numberOfSections(in tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 3
    }
    
    /// Returns the title of the existing sections.
    /// Uses `kCacheSection`, `kUnitsSection`and `kMapSourceSection` for deciding which
    /// is the section title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case kUnitsSection: return "Units"
        case kCacheSection: return "Cache"
        case kMapSourceSection: return "Map source"
        default: fatalError("Unknown section")
        }
    }
    
    /// For section `kCacheSection` returns 2, `kUnitsSection` returns 1,
    /// and for `kMapSourceSection` returns the number of tile servers defined in `GPXTileServer`
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case kCacheSection: return 2
        case kUnitsSection: return 1
        case kMapSourceSection: return GPXTileServer.count
        default: fatalError("Unknown section")
        }
    }
    
    /// For `kCacheSection`:
    /// 1. If `indexPath.row` is equal to `kUserOfflineCacheCell`, returns a cell with a checkmark
    /// 2. If `indexPath.row` is equal to `kClearCacheCell`, returns a cell with a red text
    /// `kClearCacheCell`
    ///
    /// If the section is kMapSourceSection, it returns a chekmark cell with the name of
    /// the tile server in the  `indexPath.row` index in `GPXTileServer`. The cell is marked
    /// if `selectedTileServerInt` is the same as `indexPath.row`.
    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "MapCell")
        
        // Units section
        if indexPath.section == kUnitsSection {
             switch (indexPath.row) {
             case kUseImperialUnitsCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Use imperial units?"
                if preferences.useImperial {
                    cell.accessoryType = .checkmark
                }
             default: fatalError("Unknown section")
            }
        }
        
        // Cache Section
        if indexPath.section == kCacheSection {
            switch (indexPath.row) {
            case kUseOfflineCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Offline cache"
                if preferences.useCache {
                    cell.accessoryType = .checkmark
                }
            case kClearCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = "Clear cache"
                cell.textLabel?.textColor = UIColor.red
            default: fatalError("Unknown section")
            }
        }
        
        // Map Section
        if indexPath.section == kMapSourceSection {
            //cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
            //cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"Something" ]];
            let tileServer = GPXTileServer(rawValue: indexPath.row)
            cell.textLabel?.text = tileServer!.name
            if indexPath.row == preferences.tileServerInt {
                cell.accessoryType = .checkmark
            }
            
            return cell
        }
        return cell
    }
    
    /// Performs the following actions depending on the section and row selected:
    /// 1. A cell in kCacheSection is selected:
    ///     1. kUseOfflineCacheCell: Activates or desactivates the use of cache
    ///        (`kDefaultUseCache` in defaults)
    /// 2. A cell in kMapSourceSection is selected: Updates the default key (`kDefaultsKeyTileServerInt`)
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == kUnitsSection {
            switch indexPath.row {
            case kUseImperialUnitsCell:
                let newUseImperial = !preferences.useImperial
                preferences.useImperial = newUseImperial
                print("PreferencesTableViewController: toggle imperial units to \(newUseImperial)")
                //update cell UI
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseImperial ? .checkmark : .none
                //notify the map
                self.delegate?.didUpdateUseImperial(newUseImperial)
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        }
        if indexPath.section == kCacheSection {  // 0 -> sets and unsets cache
            switch indexPath.row {
            case kUseOfflineCacheCell:
                print("toggle cache")
                let newUseCache = !preferences.useCache //toggle value
                preferences.useCache = newUseCache
                //update cell
                tableView.cellForRow(at: indexPath)?.accessoryType = newUseCache ? .checkmark : .none
                //notify the map
                self.delegate?.didUpdateUseCache(newUseCache)
            case kClearCacheCell:
                print("clear cache")
                // usage example of cache https://github.com/hyperoslo/Cache/blob/master/Playgrounds/Storage.playground/Contents.swift
                // 1 -> clears cache
                do {
                    let diskConfig = DiskConfig(name: "ImageCache")
                    let cache = try Storage(
                        diskConfig: diskConfig,
                        memoryConfig: MemoryConfig(),
                        transformer: TransformerFactory.forData()
                    )
                    //Clear cache
                    cache.async.removeAll(completion: { (result) in
                        if case .value = result {
                            print("Cache cleaned")
                            let cell = tableView.cellForRow(at: indexPath)!
                            cell.textLabel?.text = "Cache is now empty"
                            cell.textLabel?.textColor = UIColor.gray
                        }
                    })
                } catch {
                    print(error)
                }
            default:
                fatalError("didSelectRowAt: Unknown cell")
            }
        }
        if indexPath.section == kMapSourceSection { // section 1 (sets tileServerInt in defaults
            print("PreferenccesTableView Map Tile Server section Row at index:  \(indexPath.row)")
            
            //remove checkmark from selected tile server
            let selectedTileServerIndexPath = IndexPath(row: preferences.tileServerInt, section: indexPath.section)
            tableView.cellForRow(at: selectedTileServerIndexPath)?.accessoryType = .none
            
            //add checkmark to new tile server
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferences.tileServerInt = indexPath.row
            
            //update map
            self.delegate?.didUpdateTileServer((indexPath as NSIndexPath).row)
        }
        
        //unselect row
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
