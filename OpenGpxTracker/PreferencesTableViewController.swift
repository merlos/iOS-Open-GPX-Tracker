//
//  PreferencesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/10/15.
//

import Foundation
import UIKit

import Cache

/// Cache Section Id in PreferencesTableViewController
let kCacheSection = 0

/// Map Source Section Id in PreferencesTableViewController
let kMapSourceSection = 1

/// Cell Id for Use offline cache in CacheSection of PreferencesTableViewController
let kUseOfflineCacheCell = 0

/// Cell Id for Clear cache in CacheSection of PreferencesTableViewController
let kClearCacheCell = 1


/// Key on Defaults for the Tile Server integer.
let kDefaultsKeyTileServerInt: String = "TileServerInt"
/// Key on Defaults for the use cache setting.
let kDefaultsKeyUseCache: String = "UseCache"

/// Key on Defaults for the use of imperial units.
let kDefaultsKeyUsesImperial: String = "UsesImperial"

///
/// There are two preferences available:
///  * use or not cache
///  * select the map source (tile server)
///
/// Preferences are kept on UserDefaults with the keys `kDefaultKeyTileServerInt` (Int)
/// and `kDefaultUseCache`` (Bool)
///
class PreferencesTableViewController: UITableViewController, UINavigationBarDelegate {
    
    /// Tile server selected
    var selectedTileServerInt = -1
    
    /// Current use of cache
    var currentUseCache: Bool = true
    
    /// UserDefaults.standard shortcut
    let defaults = UserDefaults.standard
    
    /// Delegate for this table view controller.
    weak var delegate: PreferencesTableViewControllerDelegate?
    
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
        
        //Load preferences from defaults
        selectedTileServerInt = defaults.integer(forKey: kDefaultsKeyTileServerInt)
        if let useCacheFromDefaults = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            print("PreferencesTableViewController:: loaded preference useCache= \(useCacheFromDefaults)");
            self.currentUseCache = useCacheFromDefaults
        }
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
    
    /// Returns 2 (one section is for "Cache" and the second one is for  "Map Source"
    override func numberOfSections(in tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 2
    }
    
    /// Returns the title of the existing sections.
    /// Uses `kCacheSection` and `kMapSourceSection` for deciding which section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case kCacheSection: return "Cache"
        case kMapSourceSection: return "Map source"
        default: fatalError("Unknown section")
        }
    }
    
    /// For section `kCacheSection` resturns 2 and for `kMapSourceSection` returns the number of
    /// tile servers defined in `GPXTileServer`
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case kCacheSection: return 2
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
    
    /// Performs the following actions depending on the section and row selected:
    /// 1. A cell in kCacheSection is selected:
    ///     1. kUseOfflineCacheCell: Activates or desactivates the use of cache
    ///        (`kDefaultUseCache` in defaults)
    /// 2. A cell in kMapSourceSection is selected: Updates the default key (`kDefaultsKeyTileServerInt`)
    ///
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == kCacheSection {  // 0 -> sets and unsets cache
            switch indexPath.row {
            case kUseOfflineCacheCell:
                print("toggle cache")
                let newUseCache = !self.currentUseCache //toggle value
                defaults.set(newUseCache, forKey: kDefaultsKeyUseCache)
                self.currentUseCache = newUseCache
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
