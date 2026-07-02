//
//  AppDelegate.swift
//  OpenGpxTracker
//
//  Created by merlos on 13/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

/// Application delegate for Open GPX Tracker.
///
/// Retained for URL handling (`application(_:open:options:)`) and
/// Watch Connectivity (`WCSessionDelegate`).  The SwiftUI `@main` entry
/// point (`OpenGpxTrackerApp`) adapts this class via `@UIApplicationDelegateAdaptor`.
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Default placeholder function
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    /// Default placeholder function
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. 
        // This can occur for certain types of temporary interruptions 
        // (such as an incoming phone call or SMS message) 
        // or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. 
        // Games should use this method to pause the game.
    }

    /// Default placeholder function
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, 
        // and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of 
        // applicationWillTerminate: when the user quits.
    }

    /// Default placeholder function
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; 
        // here you can undo many of the changes made on entering the background.
    }

    /// Default placeholder function
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 9.0, *) {
            if WCSession.isSupported() {
                print("AppDelegate:: WCSession is supported")
                let session = WCSession.default
                session.delegate = self
                session.activate()
                print("AppDelegate:: WCSession activated")
            } else {
                print("AppDelegate:: WCSession is not supported")
            }
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. 
        // If the application was previously in the background, optionally refresh the user interface.
    }

    /// Default placeholder function
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        // self.saveContext()
    }
    
    /// Default pandle load GPX file
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("load gpx File: \(url.absoluteString)")
        let fileManager = FileManager.default
        do {
            _ = url.startAccessingSecurityScopedResource()
            try fileManager.copyItem(at: url, to: GPXFileManager.GPXFilesFolderURL.appendingPathComponent(url.lastPathComponent))
            url.stopAccessingSecurityScopedResource()
        } catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        
        // post a notification when a file is received through this method.
        NotificationCenter.default.post(name: .didReceiveFileFromURL, object: nil)
        
        return true
    }
    
    // MARK: - Core Data stack

    /// Convenience accessor for the shared Core Data stack.
    var managedObjectContext: NSManagedObjectContext {
        CoreDataStack.shared.managedObjectContext
    }

    // MARK: - Core Data Saving support

    /// Default placeholder function
    func saveContext () {
        CoreDataStack.shared.saveContext()
    }
}

// MARK: WCSessionDelegate

///
/// Handles file transfers from Apple Watch companion app
/// Should be non intrusive to UI, handling all in the background.

/// File received are automatically moved to default location which stores all GPX files
///
/// Only available > iOS 9
///
@available(iOS 9.0, *)
extension AppDelegate: WCSessionDelegate {
    
    /// called when `WCSession` goes inactive. Does nothing but display a debug message.
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("AppDelegate:: WCSession has become inactive")
    }
    
    /// called when `WCSession` goes inactive. Does nothing but display a debug message
    func sessionDidDeactivate(_ session: WCSession) {
        print("AppDelegate:: WCSession has deactivated")
    }
    
    /// called when activation did complete. Does nothing but display a debug message.
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState {
        case .activated:
            print("AppDelegate:: activationDidCompleteWithActivationState: WCSession activated")
        case .inactive:
            print("AppDelegate:: activationDidCompleteWithActivationState: WCSession inactive")
        case .notActivated:
            print("AppDelegate:: activationDidCompleteWithActivationState: WCSession not activated, error:\(String(describing: error))")
            
        default: break
        }
    }
    
    /// Called when a file is received from Apple Watch.
    /// Displays a popup informing about the reception of the file.
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        // swiftlint:disable:next force_cast
        let fileName = file.metadata!["fileName"] as! String?
        DispatchQueue.global().sync {
            GPXFileManager.moveFrom(file.fileURL, fileName: fileName)
            print("ViewController:: Received file from WatchConnectivity Session")
        }
        
        // posts notification that file is received from apple watch
        NotificationCenter.default.post(name: .didReceiveFileFromAppleWatch, object: nil, userInfo: ["fileName": fileName ?? ""])
    }
}

/// Notifications for file receival from external source.
extension Notification.Name {
    
    /// Use when a file is received from external source.
    static let didReceiveFileFromURL = Notification.Name("didReceiveFileFromURL")
    
    /// Use when a file is received from Apple Watch.
    static let didReceiveFileFromAppleWatch = Notification.Name("didReceiveFileFromAppleWatch")
}
