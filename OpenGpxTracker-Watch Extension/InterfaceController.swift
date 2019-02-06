//
//  InterfaceController.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 5/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import WatchKit
import Foundation
import MapKit
import CoreLocation
import CoreGPX

//Button colors
let kPurpleButtonBackgroundColor: UIColor =  UIColor(red: 146.0/255.0, green: 166.0/255.0, blue: 218.0/255.0, alpha: 0.90)
let kGreenButtonBackgroundColor: UIColor = UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)
let kRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.90)
let kBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.90)
let kDisabledBlueButtonBackgroundColor: UIColor = UIColor(red: 74.0/255.0, green: 144.0/255.0, blue: 226.0/255.0, alpha: 0.10)
let kDisabledRedButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.10)
let kWhiteBackgroundColor: UIColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 0.90)

//Accesory View buttons tags
let kDeleteWaypointAccesoryButtonTag = 666
let kEditWaypointAccesoryButtonTag = 333

let kNotGettingLocationText = "Not getting location"
let kUnknownAccuracyText = "±···m"
let kUnknownSpeedText = "·.··"

let kEditWaypointAlertViewTag = 33
let kSaveSessionAlertViewTag = 88
let kLocationServicesDeniedAlertViewTag = 69
let kLocationServicesDisabledAlertViewTag = 70

/// Size for small buttons
let kButtonSmallSize: CGFloat = 48.0
/// Size for large buttons
let kButtonLargeSize: CGFloat = 96.0
/// Separation between buttons
let kButtonSeparation: CGFloat = 6.0

/// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy6 = 6.0
let kSignalAccuracy5 = 11.0
let kSignalAccuracy4 = 31.0
let kSignalAccuracy3 = 51.0
let kSignalAccuracy2 = 101.0
let kSignalAccuracy1 = 201.0

class InterfaceController: WKInterfaceController {

    @IBOutlet var trackerTimer: WKInterfaceTimer!
    @IBOutlet var trackerDistanceLabel: WKInterfaceLabel!
    @IBOutlet var newPinButton: WKInterfaceButton!
    @IBOutlet var trackerButton: WKInterfaceButton!
    @IBOutlet var saveButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    @IBOutlet var followUserButton: WKInterfaceButton!
    @IBOutlet var trackerMap: WKInterfaceMap!
    
    //MapView
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    /// Map View
    //var map: GPXMapView
    // not updated for Watch (WKInterfaceMap only)
    
    /// Map View delegate
    //let mapViewDelegate = MapViewDelegate()
    // not updated for Watch
    
    //Status Vars
    var stopWatch = StopWatch()
    var lastGpxFilename: String = ""
    var wasSentToBackground: Bool = false //Was the app sent to background
    var isDisplayingLocationServicesDenied: Bool = false
    
    /// Has the map any waypoint?
    var hasWaypoints: Bool = false {
        /// Whenever it is updated, if it has waypoints it sets the save and reset button
        didSet {
            if hasWaypoints {
                saveButton.setBackgroundColor(kBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kRedButtonBackgroundColor)
            }
        }
    }
    
    /// Defines the different statuses regarding tracking current user location.
    enum GpxTrackingStatus {
        
        /// Tracking has not started or map was reset
        case notStarted
        
        /// Tracking is ongoing
        case tracking
        
        /// Tracking is paused (the map has some contents)
        case paused
    }
    
    /// Tells what is the current status of the Map Instance.
    var gpxTrackingStatus: GpxTrackingStatus = GpxTrackingStatus.notStarted {
        didSet {
            print("gpxTrackingStatus changed to \(gpxTrackingStatus)")
            switch gpxTrackingStatus {
            case .notStarted:
                print("switched to non started")
                // set Tracker button to allow Start
                trackerButton.setTitle("Start Tracking")
                trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
                //save & reset button to transparent.
                saveButton.setBackgroundColor(kDisabledBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kDisabledRedButtonBackgroundColor)
                //reset clock
                stopWatch.reset()
                //timeLabel.text = stopWatch.elapsedTimeString -> not yet
                
                //map.clearMap() //clear map
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                //totalTrackedDistanceLabel.distance = (map.totalTrackedDistance)
                //currentSegmentDistanceLabel.distance = (map.currentSegmentDistance)
                
                /*
                 // XXX Left here for reference
                 UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                 self.trackerButton.hidden = true
                 self.pauseButton.hidden = false
                 }, completion: {(f: Bool) -> Void in
                 println("finished animation start tracking")
                 })
                 */
                
            case .tracking:
                print("switched to tracking mode")
                // set trackerButton to allow Pause
                trackerButton.setTitle("Pause")
                trackerButton.setBackgroundColor(kPurpleButtonBackgroundColor)
                //activate save & reset buttons
                saveButton.setBackgroundColor(kBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kRedButtonBackgroundColor)
                // start clock
                self.stopWatch.start()
                self.trackerTimer.start()
                
            case .paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle("Resume")
                self.trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
                // activate save & reset (just in case switched from .NotStarted)
                saveButton.setBackgroundColor(kBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kRedButtonBackgroundColor)
                //pause clock
                self.stopWatch.stop()
                self.trackerTimer.stop()
                // start new track segment
                //self.map.startNewTrackSegment()
            }
        }
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //stopWatch.delegate = self
        //locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
        
        //locationManager.startUpdatingHeading()
        // WatchKit does not have heading
        
        addNotificationObservers()
        
        
        trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
        
        newPinButton.setBackgroundColor(kWhiteBackgroundColor)
        
        saveButton.setBackgroundColor(kDisabledRedButtonBackgroundColor)
        
        resetButton.setBackgroundColor(kDisabledRedButtonBackgroundColor)
        
        
    }
    
    
    ///
    /// Main Start/Pause Button was tapped.
    ///
    /// It sets the status to tracking or paused.
    ///
    @IBAction func trackerButtonTapped() {
        print("startGpxTracking::")
        switch gpxTrackingStatus {
        case .notStarted:
            gpxTrackingStatus = .tracking
        case .tracking:
            gpxTrackingStatus = .paused
        case .paused:
            //set to tracking
            gpxTrackingStatus = .tracking
        }
        
    }
    @IBAction func addPinAtMyLocation() {
    }
    @IBAction func saveButtonTapped() {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) && !self.hasWaypoints {
            return
        }
        
        /*
        let alert = UIAlertView(title: "Save as", message: "Enter GPX session name", delegate: self, cancelButtonTitle: "Cancel")
        
        alert.addButton(withTitle: "Save")
        alert.alertViewStyle = .plainTextInput
        alert.tag = kSaveSessionAlertViewTag
        alert.textField(at: 0)?.clearButtonMode = .always
        alert.textField(at: 0)?.text = lastGpxFilename.isEmpty ? defaultFilename() : lastGpxFilename
        alert.show()
        //alert.textFieldAtIndex(0)?.selectAll(self)
 */
        
    }
    
    ///
    /// Triggered when reset button was tapped.
    ///
    /// It sets map to status .notStarted which clears the map.
    ///
    @IBAction func resetButtonTapped() {
        self.gpxTrackingStatus = .notStarted
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        removeNotificationObservers()
    }
    
    ///
    /// Asks the system to notify the app on some events
    ///
    /// Current implementation requests the system to notify the app:
    ///
    ///  1. whenever it enters background
    ///  2. whenever it becomes active
    ///  3. whenever it will terminate
    ///
    
    func addNotificationObservers() {
        let notificationCenter = NotificationCenter.default
        /*
        notificationCenter.addObserver(self, selector: #selector(InterfaceController.wasSentToBackground),
                                       name: "didEnterBackgroundNotification", object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        notificationCenter.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
 */
    }
    
    
    ///
    /// Removes the notification observers
    ///
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// returns a string with the format of current date dd-MMM-yyyy-HHmm' (20-Jun-2018-1133)
    ///
    
    func defaultFilename() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
        print("fileName:" + dateFormatter.string(from: Date()))
        return dateFormatter.string(from: Date())
    }
    
    ///
    /// Called when the application Becomes active (background -> foreground) this function verifies if
    /// it has permissions to get the location.
    ///
    @objc func applicationDidBecomeActive() {
        print("InterfaceController:: applicationDidBecomeActive wasSentToBackground: \(wasSentToBackground) locationServices: \(CLLocationManager.locationServicesEnabled())")
        
        //If the app was never sent to background do nothing
        if !wasSentToBackground {
            return
        }
        checkLocationServicesStatus()
        locationManager.startUpdatingLocation()
        //locationManager.startUpdatingHeading()
    }
    
    ///
    /// Actions to do in case the app entered in background
    ///
    /// In current implementation if the app is not tracking it requests the OS to stop
    /// sharing the location to save battery.
    ///
    ///
    @objc func didEnterBackground() {
        wasSentToBackground = true // flag the application was sent to background
        print("InterfaceController:: didEnterBackground")
        if gpxTrackingStatus != .tracking {
            locationManager.stopUpdatingLocation()
        }
    }
    
    ///
    /// Actions to do when the app will terminate
    ///
    /// In current implementation it removes all the temporary files that may have been created
    @objc func applicationWillTerminate() {
        print("viewController:: applicationWillTerminate")
        GPXFileManager.removeTemporaryFiles()
    }
    
    ///
    /// Triggered when follow Button is taped.
    //
    /// Trogles between following or not following the user, that is, automatically centering the map
    //  in current user´s position.
    ///
    /*
    @objc func followButtonTroggler() {
        self.followUser = !self.followUser
    }
    */
    
    
    ///
    /// Checks the location services status
    /// - Are location services enabled (access to location device wide)? If not => displays an alert
    /// - Are location services allowed to this app? If not => displays an alert
    ///
    /// - Seealso: displayLocationServicesDisabledAlert, displayLocationServicesDeniedAlert
    ///
    func checkLocationServicesStatus() {
        //Are location services enabled?
        if !CLLocationManager.locationServicesEnabled() {
            displayLocationServicesDisabledAlert()
            return
        }
        //Does the app have permissions to use the location servies?
        if !([.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())) {
            displayLocationServicesDeniedAlert()
            return
        }
    }
    
    ///
    /// Displays an alert that informs the user that location services are disabled.
    ///
    /// When location services are disabled is for all applications, not only this one.
    ///
    func displayLocationServicesDisabledAlert() {
        let button = WKAlertAction(title: "Cancel", style: .cancel) {
            print("LocationServicesDisabledAlert: cancel pressed")
        }
        
        presentAlert(withTitle: "Location services disabled", message: "Go to settings and enable location", preferredStyle: .alert, actions: [button])
    }
    
    
    ///
    /// Displays an alert that informs the user that access to location was denied for this app (other apps may have access).
    /// It also dispays a button allows the user to go to settings to activate the location.
    ///
    func displayLocationServicesDeniedAlert() {
        if isDisplayingLocationServicesDenied {
            return // display it only once.
        }
        let button = WKAlertAction(title: "Cancel", style: .cancel) {
            print("LocationServicesDeniedAlert: cancel pressed")
        }
        
        presentAlert(withTitle: "Access to location denied", message: "On Location settings, allow always access to location for GPX Tracker", preferredStyle: .alert, actions: [button])
    }

}

