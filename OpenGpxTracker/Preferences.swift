//
//  Preferences.swift
//  OpenGpxTracker
//
//  Created by merlos on 04/05/2019.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import Foundation


/// Key on Defaults for the Tile Server integer.
let kDefaultsKeyTileServerInt: String = "TileServerInt"

/// Key on Defaults for the use cache setting.
let kDefaultsKeyUseCache: String = "UseCache"

/// Key on Defaults for the use of imperial units.
let kDefaultsKeyUseImperial: String = "UseImperial"


/// A class to handle app preferences in one single place.
///
class Preferences: NSObject {

    //shared preferences
    static let shared = Preferences()
    
    private var _useImperial: Bool = false
    private var _useCache: Bool = true
    private var _tileServer: GPXTileServer = .apple
    
    /// UserDefaults.standard shortcut
    private let defaults = UserDefaults.standard
    
    private override init() {
        //loads preferences into private vars
     
        // Use Imperial units
        if let useImperialDefaults = defaults.object(forKey: kDefaultsKeyUseImperial) as? Bool {
            print("** Preferences:: loaded from defaults. useImperial: \(useImperialDefaults)")
            _useImperial = useImperialDefaults
        } else { // get from locale config
            let locale = NSLocale.current
            _useImperial = !locale.usesMetricSystem
            print("** Preferences:: NO defaults for useImperial. Using locale: \(locale.languageCode ?? "unknown") useImperial: \(_useImperial) usesMetric:\(locale.usesMetricSystem)")
        }
    
        // Use cache
        if let useCacheFromDefaults = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            _useCache = useCacheFromDefaults
            print("Preferences:: loaded preference from defaults useCache= \(useCacheFromDefaults)");
        }
        
        // Map Tile server
        if var tileServerInt = defaults.object(forKey: kDefaultsKeyTileServerInt) as? Int {
            // Check in case it was a tile server that is no longer supported
            tileServerInt = tileServerInt >= GPXTileServer.count ? GPXTileServer.apple.rawValue : tileServerInt
            _tileServer = GPXTileServer(rawValue: tileServerInt)!
            print("** Preferences:: loaded preference from defaults tileServerInt \(tileServerInt)")
        }
    }
    
    var useImperial: Bool {
        get {
            return _useImperial
        }
        set {
            _useImperial = newValue
            defaults.set(newValue, forKey: kDefaultsKeyUseImperial)
        }
    }
    
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
    
    
    var tileServer: GPXTileServer {
        get {
            return _tileServer
        }
        
        set {
            _tileServer = newValue
             defaults.set(newValue.rawValue, forKey: kDefaultsKeyTileServerInt)
        }
    }
    
    var tileServerInt: Int {
        get {
            return _tileServer.rawValue
        }
        set {
            _tileServer = GPXTileServer(rawValue: newValue)!
             defaults.set(newValue, forKey: kDefaultsKeyTileServerInt)
           
            
        }
    }
}
