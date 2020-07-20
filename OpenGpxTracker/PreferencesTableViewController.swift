//
//  PreferencesTableViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/10/15.
//
//  Localized by nitricware on 19/08/19.
//

import Foundation
import UIKit
import CoreLocation
import MapCache

/// Units Section Id in PreferencesTableViewController
let kUnitsSection = 0

/// Cache Section Id in PreferencesTableViewController
let kCacheSection = 1

/// Map Source Section Id in PreferencesTableViewController
let kMapSourceSection = 2

/// Activity Type Section Id in PreferencesTableViewController
let kActivityTypeSection = 3

/// Default Name Section Id in PreferencesTableViewController
let kDefaultNameSection = 4

/// Cell Id of the Use Imperial units in UnitsSection
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
    var preferences: Preferences = Preferences.shared
    
    var cache: MapCache = MapCache(withConfig: MapCacheConfig(withUrlTemplate: ""))
    
    // Compute once, better performance for scrolling table view (reuse)
    /// Store cached size for reuse.
    var cachedSize = String()
    
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
        
        self.title = NSLocalizedString("PREFERENCES", comment: "no comment")
        let shareItem = UIBarButtonItem(title: NSLocalizedString("DONE", comment: "no comment"),
                                        style: UIBarButtonItem.Style.plain, target: self,
                                        action: #selector(PreferencesTableViewController.closePreferencesTableViewController))
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        let fileSize = cache.diskCache.fileSize ?? 0
        cachedSize = Int(fileSize).asFileSize()
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
    
    /// Returns 4 sections: Units, Cache, Map Source, Activity Type
    override func numberOfSections(in tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 5
    }
    
    /// Returns the title of the existing sections.
    /// Uses `kCacheSection`, `kUnitsSection`, `kMapSourceSection` and `kActivityTypeSection`
    /// for deciding which is the section title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case kUnitsSection: return NSLocalizedString("UNITS", comment: "no comment")
        case kCacheSection: return NSLocalizedString("CACHE", comment: "no comment")
        case kMapSourceSection: return NSLocalizedString("MAP_SOURCE", comment: "no comment")
        case kActivityTypeSection: return NSLocalizedString("ACTIVITY_TYPE", comment: "no comment")
        case kDefaultNameSection: return NSLocalizedString("DEFAULT_NAME_SECTION", comment: "no comment")
        default: fatalError("Unknown section")
        }
    }
    
    /// For section `kCacheSection` returns 2, for `kUnitsSection` returns 1,
    /// for `kMapSourceSection` returns the number of tile servers defined in `GPXTileServer`,
    /// and for kActivityTypeSection returns `CLActivityType.count`
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case kCacheSection: return 2
        case kUnitsSection: return 1
        case kMapSourceSection: return GPXTileServer.count
        case kActivityTypeSection: return CLActivityType.count
        case kDefaultNameSection: return 1
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
    /// If the section is kActivityTypeSection it returns a checkmark cell with the name
    /// and description of the CLActivityType whose indexPath.row matches with the activity type.
    ///
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .value1, reuseIdentifier: "MapCell")
        
        // Units section
        if indexPath.section == kUnitsSection {
             switch indexPath.row {
             case kUseImperialUnitsCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = NSLocalizedString("USE_IMPERIAL_UNITS", comment: "no comment")
                if preferences.useImperial {
                    cell.accessoryType = .checkmark
                }
             default: fatalError("Unknown section")
            }
        }
        
        // Cache Section
        if indexPath.section == kCacheSection {
            switch indexPath.row {
            case kUseOfflineCacheCell:
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = NSLocalizedString("OFFLINE_CACHE", comment: "no comment")
                
                cell.detailTextLabel?.text = cachedSize
                if preferences.useCache {
                    cell.accessoryType = .checkmark
                }
            case kClearCacheCell:
                cell = UITableViewCell(style: .value1, reuseIdentifier: "CacheCell")
                cell.textLabel?.text = NSLocalizedString("CLEAR_CACHE", comment: "no comment")
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
        }
        
        // Activity type section
        if indexPath.section == kActivityTypeSection {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ActivityCell")
            let activity = CLActivityType(rawValue: indexPath.row + 1)!
            cell.textLabel?.text = activity.name
            cell.detailTextLabel?.text = activity.description
            if indexPath.row + 1 == preferences.locationActivityTypeInt {
                cell.accessoryType = .checkmark
            }
        }
        
        // Default Name section
        if indexPath.section == kDefaultNameSection {
            let dateFormatter = DefaultDateFormat()
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultNameCell")
            cell.textLabel?.text = preferences.dateFormatPreset == -1 ? preferences.dateFormatInput : preferences.dateFormatPresetName
            let dateText = dateFormatter.getDate(processedFormat: preferences.dateFormat,
                                                 useUTC: preferences.dateFormatUseUTC,
                                                 useENLocale: preferences.dateFormatUseEN)
            cell.detailTextLabel?.text = dateText
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    /// Performs the following actions depending on the section and row selected:
    /// If the cell `kUseImperialUnitCell` in `kUnitsSection`it sets or unsets the use of imperial
    /// units (`useImperial` in `Preferences``and calls the delegate method `didUpdateUseImperial`.
    ///
    /// If a cell in kCacheSection is selected and the cell is
    ///     1. kUseOfflineCacheCell: Activates or desactivates the `useCache` in `Preferences`,
    ///        and calls the delegate method `didUpdateUseCache`
    ///     2. KClearCacheCacheCell: Clears the current cache and calls
    ///
    /// If a cell in `kMapSourceSection` is selected: Updates `tileServerInt` in `Preferences` and
    /// calls the delegate method `didUpdateTileServer`
    ///
    /// If a cell in `kActivitySection` is selected: Updates the `activityType` in `Preferences` and
    /// calls the delegate method `didUpdateActivityType`.
    ///
    /// In each case checks or unchecks the corresponding cell in the UI.
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
                //Create a cache
                cache.clear {
                    print("Cache cleaned")
                    let cell = tableView.cellForRow(at: indexPath)!
                    cell.textLabel?.text = NSLocalizedString("CACHE_IS_EMPTY", comment: "no comment")
                    cell.textLabel?.textColor = UIColor.gray
                    //Clear the size text
                    let cell2 = tableView.cellForRow(at: IndexPath(row: kUseOfflineCacheCell, section: kCacheSection))
                    self.cachedSize = 0.asFileSize()
                    cell2?.detailTextLabel?.text = self.cachedSize
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
        
        if indexPath.section == kActivityTypeSection {
            print("PreferencesTableView Activity Type section Row at index:  \(indexPath.row + 1)")
            let selected = IndexPath(row: preferences.locationActivityTypeInt - 1, section: indexPath.section)
            
            tableView.cellForRow(at: selected)?.accessoryType = .none
            
            //add checkmark to new tile server
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            preferences.locationActivityTypeInt = indexPath.row + 1 // +1 as activityType raw value starts at index 1
            
            self.delegate?.didUpdateActivityType((indexPath as NSIndexPath).row + 1)
        }
        
        if indexPath.section == kDefaultNameSection {
            print("PreferencesTableView Default Name cell clicked")
            self.navigationController?.pushViewController(DefaultNameSetupViewController(style: .grouped), animated: true)
        }
        
        //unselect row
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
