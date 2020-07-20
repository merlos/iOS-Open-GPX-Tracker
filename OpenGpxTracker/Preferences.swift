//
//  Preferences.swift
//  OpenGpxTracker
//
//  Created by merlos on 04/05/2019.
//  Copyright © 2019 TransitBox. All rights reserved.
//
// Shared file: this file is also included in the OpenGpxTracker-Watch Extension target.

import Foundation
import CoreLocation

/// Key on Defaults for the Tile Server integer.
let kDefaultsKeyTileServerInt: String = "TileServerInt"

/// Key on Defaults for the use cache setting.
let kDefaultsKeyUseCache: String = "UseCache"

/// Key on Defaults for the use of imperial units.
let kDefaultsKeyUseImperial: String = "UseImperial"

/// Key on Defaults for the current selected activity type.
let kDefaultsKeyActivityType: String = "ActivityType"

/// Key on Defaults for the current date format..
let kDefaultsKeyDateFormat: String = "DateFormat"

/// Key on Defaults for the current input date format
let kDefaultsKeyDateFormatInput: String = "DateFormatPresetInput"

/// Key on Defaults for the current selected date format preset cell index.
let kDefaultsKeyDateFormatPreset: String = "DateFormatPreset"

/// Key on Defaults for the current selected date format, to use UTC time or not..
let kDefaultsKeyDateFormatUseUTC: String = "DateFormatPresetUseUTC"

/// Key on Defaults for the current selected date format, to use local Locale or `en_US_POSIX`
let kDefaultsKeyDateFormatUseEN: String = "DateFormatPresetUseEN"

/// A class to handle app preferences in one single place.
/// When the app starts for the first time the following preferences are set:
///
/// * useCache = true
/// * useImperial = whatever is set by current locale (NSLocale.usesMetricUnits) or false
/// * tileServer = .apple
///
class Preferences: NSObject {

    /// Shared preferences singleton.
    /// Usage:
    ///      var preferences: Preferences = Preferences.shared
    ///      print (preferences.useCache)
    ///
    static let shared = Preferences()
    
    /// In memory value of the preference.
    private var _useImperial: Bool = false
    
    /// In memory value of the preference.
    private var _useCache: Bool = true
    
    /// In memory value of the preference.
    private var _tileServer: GPXTileServer = .apple
    
    /// In memory value of the preference.
    private var _activityType: CLActivityType = .other
    
    ///
    private var _dateFormat = "dd-MMM-yyyy-HHmm"
    
    ///
    private var _dateFormatInput = "{dd}-{MMM}-{yyyy}-{HH}{mm}"
    
    ///
    private var _dateFormatPreset: Int = 0
    
    ///
    private var _dateFormatUseUTC: Bool = false
    
    ///
    private var _dateFormatUseEN: Bool = false
    
    /// UserDefaults.standard shortcut
    private let defaults = UserDefaults.standard
    
    /// Loads preferences from UserDefaults.
    private override init() {
        //loads preferences into private vars
     
        // Use Imperial units
        if let useImperialDefaults = defaults.object(forKey: kDefaultsKeyUseImperial) as? Bool {
            print("** Preferences:: loaded from defaults. useImperial: \(useImperialDefaults)")
            _useImperial = useImperialDefaults
        } else { // get from locale config
            let locale = NSLocale.current
            _useImperial = !locale.usesMetricSystem
            let langCode = locale.languageCode ?? "unknown"
            let useMetric = locale.usesMetricSystem
            print("** Preferences:: NO defaults for useImperial. Using locale: \(langCode) useImperial: \(_useImperial) usesMetric:\(useMetric)")
        }
    
        // Use cache
        if let useCacheFromDefaults = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            _useCache = useCacheFromDefaults
            print("Preferences:: loaded preference from defaults useCache= \(useCacheFromDefaults)")
        }
        
        // Map Tile server
        if var tileServerInt = defaults.object(forKey: kDefaultsKeyTileServerInt) as? Int {
            // Check in case it was a tile server that is no longer supported
            tileServerInt = tileServerInt >= GPXTileServer.count ? GPXTileServer.apple.rawValue : tileServerInt
            _tileServer = GPXTileServer(rawValue: tileServerInt)!
            print("** Preferences:: loaded preference from defaults tileServerInt \(tileServerInt)")
        }
        
        // load previous activity type
        if let activityTypeInt = defaults.object(forKey: kDefaultsKeyActivityType) as? Int {
            _activityType = CLActivityType(rawValue: activityTypeInt)!
            print("** Preferences:: loaded preference from defaults activityTypeInt \(activityTypeInt)")
        }
        
        // load previous date format
        if let dateFormatStr = defaults.object(forKey: kDefaultsKeyDateFormat) as? String {
            _dateFormat = dateFormatStr
            print("** Preferences:: loaded preference from defaults dateFormatStr \(dateFormatStr)")
        }
        
        // load previous date format (usr input)
        if let dateFormatStrIn = defaults.object(forKey: kDefaultsKeyDateFormatInput) as? String {
            _dateFormatInput = dateFormatStrIn
            print("** Preferences:: loaded preference from defaults dateFormatStrIn \(dateFormatStrIn)")
        }
        
        // load previous date format preset
        if let dateFormatPresetInt = defaults.object(forKey: kDefaultsKeyDateFormatPreset) as? Int {
            _dateFormatPreset = dateFormatPresetInt
            print("** Preferences:: loaded preference from defaults dateFormatPresetInt \(dateFormatPresetInt)")
        }
        
        // load previous date format, to use UTC time instead of local time
        if let dateFormatUTCBool = defaults.object(forKey: kDefaultsKeyDateFormatUseUTC) as? Bool {
            _dateFormatUseUTC = dateFormatUTCBool
            print("** Preferences:: loaded preference from defaults dateFormatPresetUTCBool \(dateFormatUTCBool)")
        }
        
        // load previous date format, to use EN locale instead of local locale
        if let dateFormatENBool = defaults.object(forKey: kDefaultsKeyDateFormatUseEN) as? Bool {
            _dateFormatUseEN = dateFormatENBool
            print("** Preferences:: loaded preference from defaults dateFormatPresetENBool \(dateFormatENBool)")
        }
    }
    
    /// If true, user prefers to display imperial units (miles, feets). Otherwise metric units
    /// are displayed.
    var useImperial: Bool {
        get {
            return _useImperial
        }
        set {
            _useImperial = newValue
            defaults.set(newValue, forKey: kDefaultsKeyUseImperial)
        }
    }
    
    /// Gets and sets if user wants to use offline cache.
    var useCache: Bool {
        get {
            return _useCache
        }
        set {
            _useCache = newValue
            //Set defaults
            defaults.set(newValue, forKey: kDefaultsKeyUseCache)
        }
    }
    
    /// Gets and sets user preference of the map tile server.
    var tileServer: GPXTileServer {
        get {
            return _tileServer
        }
        
        set {
            _tileServer = newValue
             defaults.set(newValue.rawValue, forKey: kDefaultsKeyTileServerInt)
        }
    }
    
    /// Get and sets user preference of the map tile server as Int.
    var tileServerInt: Int {
        get {
            return _tileServer.rawValue
        }
        set {
            _tileServer = GPXTileServer(rawValue: newValue)!
             defaults.set(newValue, forKey: kDefaultsKeyTileServerInt)
        }
    }
    /// Gets and sets the type of activity preference
    var locationActivityType: CLActivityType {
        get {
            return _activityType
        }
        set {
            _activityType = newValue
            defaults.set(newValue.rawValue, forKey: kDefaultsKeyActivityType)
        }
    }
    
    /// Gets and sets the activity type as its int value
    var locationActivityTypeInt: Int {
        get {
            return _activityType.rawValue
        }
        set {
            _activityType = CLActivityType(rawValue: newValue)!
            defaults.set(newValue, forKey: kDefaultsKeyActivityType)
        }
    }
    
    /// Gets and sets the date formatter friendly date format
    var dateFormat: String {
        get {
            return _dateFormat
        }
        
        set {
             _dateFormat = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormat)
        }
    }
    
    /// Gets and sets the user friendly input date format
    var dateFormatInput: String {
        get {
            return _dateFormatInput
        }
        
        set {
             _dateFormatInput = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatInput)
        }
    }
    
    /// Get and sets user preference of date format presets. (-1 if custom)
    var dateFormatPreset: Int {
        get {
            return _dateFormatPreset
        }
        set {
            _dateFormatPreset = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatPreset)
        }
    }
    
    /// Get date format preset name
    var dateFormatPresetName: String {
        let presets =  ["Defaults", "ISO8601 (UTC)", "ISO8601 (UTC offset)", "Day, Date at time (12 hr)", "Day, Date at time (24 hr)"]
        return _dateFormatPreset < presets.count ? presets[_dateFormatPreset] : "???"
    }
    
    /// Get and sets whether to use UTC for date format
    var dateFormatUseUTC: Bool {
        get {
            return _dateFormatUseUTC
        }
        set {
            _dateFormatUseUTC = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatUseUTC)
        }
    }
    
    /// Get and sets whether to use local locale or EN
    var dateFormatUseEN: Bool {
        get {
            return _dateFormatUseEN
        }
        set {
            _dateFormatUseEN = newValue
             defaults.set(newValue, forKey: kDefaultsKeyDateFormatUseEN)
        }
    }
}
