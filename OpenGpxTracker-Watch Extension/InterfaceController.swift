//
//  InterfaceController.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 5/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import WatchKit
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

let kNotGettingLocationText = NSLocalizedString("NO_LOCATION", comment: "no comment")
let kUnknownAccuracyText = "±···"
let kUnknownSpeedText = "·.··"
let kUnknownAltitudeText = "···"

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

///
/// Main View Controller of the Watch Application. It is loaded when the application is launched
///
/// Displays a set the buttons to control the tracking, along with additional infomation.
///
///
class InterfaceController: WKInterfaceController {

    @IBOutlet var newPinButton: WKInterfaceButton!
    @IBOutlet var trackerButton: WKInterfaceButton!
    @IBOutlet var saveButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var totalTrackedDistanceLabel: WKInterfaceLabel!
    @IBOutlet var signalImageView: WKInterfaceImage!
    @IBOutlet var signalAccuracyLabel: WKInterfaceLabel!
    @IBOutlet var coordinatesLabel: WKInterfaceLabel!
    @IBOutlet var altitudeLabel: WKInterfaceLabel!
    @IBOutlet var speedLabel: WKInterfaceLabel!

    /// Location Manager
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    /// Preferences loader
    let preferences = Preferences.shared
    
    /// Underlying class that handles background stuff
    let map = GPXMapView() // not even a map view. Considering renaming
    
    //Status Vars
    var stopWatch = StopWatch()
    var lastGpxFilename: String = ""
    var wasSentToBackground: Bool = false //Was the app sent to background
    var isDisplayingLocationServicesDenied: Bool = false
    
    /// Does the 'file' have any waypoint?
    var hasWaypoints: Bool = false {
        /// Whenever it is updated, if it has waypoints it sets the save and reset button
        didSet {
            if hasWaypoints {
                saveButton.setBackgroundColor(kBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kRedButtonBackgroundColor)
            }
        }
    }
    
    // Signal accuracy images
    let signalImage0 = UIImage(named: "signal0")
    let signalImage1 = UIImage(named: "signal1")
    let signalImage2 = UIImage(named: "signal2")
    let signalImage3 = UIImage(named: "signal3")
    let signalImage4 = UIImage(named: "signal4")
    let signalImage5 = UIImage(named: "signal5")
    let signalImage6 = UIImage(named: "signal6")
    
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
                trackerButton.setTitle(NSLocalizedString("START_TRACKING", comment: "no comment"))
                trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
                //save & reset button to transparent.
                saveButton.setBackgroundColor(kDisabledBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kDisabledRedButtonBackgroundColor)
                //reset clock
                stopWatch.reset()
                timeLabel.setText(stopWatch.elapsedTimeString)
                
                map.reset() //reset gpx logging
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                totalTrackedDistanceLabel.setText(map.totalTrackedDistance.toDistance(useImperial: preferences.useImperial))
                
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
                trackerButton.setTitle(NSLocalizedString("PAUSE", comment: "no comment"))
                trackerButton.setBackgroundColor(kPurpleButtonBackgroundColor)
                //activate save & reset buttons
                saveButton.setBackgroundColor(kBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kRedButtonBackgroundColor)
                // start clock
                self.stopWatch.start()
                
            case .paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle(NSLocalizedString("RESUME", comment: "no comment"))
                self.trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
                // activate save & reset (just in case switched from .NotStarted)
                saveButton.setBackgroundColor(kBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kRedButtonBackgroundColor)
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                self.map.startNewTrackSegment()
            }
        }
    }
    
    /// Editing Waypoint Temporal Reference
    var lastLocation: CLLocation? //Last point of current segment.

    override func awake(withContext context: Any?) {
        print("InterfaceController:: awake")
        super.awake(withContext: context)

        totalTrackedDistanceLabel.setText( 0.00.toDistance(useImperial: preferences.useImperial))
        
        if gpxTrackingStatus == .notStarted {
            trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
            newPinButton.setBackgroundColor(kWhiteBackgroundColor)
            saveButton.setBackgroundColor(kDisabledRedButtonBackgroundColor)
            resetButton.setBackgroundColor(kDisabledBlueButtonBackgroundColor)
            
            coordinatesLabel.setText(kNotGettingLocationText)
            signalAccuracyLabel.setText(kUnknownAccuracyText)
            altitudeLabel.setText(kUnknownAltitudeText)
            speedLabel.setText(kUnknownSpeedText)
            signalImageView.setImage(signalImage0)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
         print("InterfaceController:: willActivate")
        super.willActivate()
        self.setTitle(NSLocalizedString("GPX_TRACKER", comment: "no comment"))
        
        stopWatch.delegate = self
        
        locationManager.delegate = self
        checkLocationServicesStatus()
        locationManager.startUpdatingLocation()
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("InterfaceController:: didDeactivate called")
        
        if gpxTrackingStatus != .tracking {
            print("InterfaceController:: didDeactivate will stopUpdatingLocation")
            locationManager.stopUpdatingLocation()
        }
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
    
    ///
    /// Add Pin (waypoint) Button was tapped.
    ///
    /// It adds a new waypoint with the current coordinates while tracking is underway.
    ///
    @IBAction func addPinAtMyLocation() {
        if let currentCoordinates = locationManager.location?.coordinate {
            let altitude = locationManager.location?.altitude
            let waypoint = GPXWaypoint(coordinate: currentCoordinates, altitude: altitude)
            map.addWaypoint(waypoint)
            print("Adding waypoint at \(currentCoordinates)")
            self.hasWaypoints = true
        }
        
    }
    
    ///
    /// Save Button was tapped.
    ///
    /// Saves current track and waypoints as a GPX file, with a default filename of date and time.
    ///
    @IBAction func saveButtonTapped(withReset: Bool = false) {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) && !self.hasWaypoints {
            return
        }
        let filename = defaultFilename()
        let gpxString = self.map.exportToGPXString()
        GPXFileManager.save(filename, gpxContents: gpxString)
        self.lastGpxFilename = filename
        //print(gpxString)
        
        if withReset {
            self.gpxTrackingStatus = .notStarted
        }
        
        /// Just a 'done' button, without
        let action = WKAlertAction(title: "Done", style: .default) {}
        
        presentAlert(withTitle: NSLocalizedString("FILE_SAVED_TITLE", comment: "no comment"),
                     message: "\(filename).gpx", preferredStyle: .alert, actions: [action])
        
    }
    
    ///
    /// Triggered when reset button was tapped.
    ///
    /// It sets map to status .notStarted which clears the map.
    ///
    @IBAction func resetButtonTapped() {
        
        let cancelOption = WKAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"), style: .cancel) {}
        let saveAndStartOption = WKAlertAction(title: NSLocalizedString("SAVE_START_NEW", comment: "no comment"), style: .default) {
            self.saveButtonTapped(withReset: true)
        }
        let deleteOption = WKAlertAction(title: NSLocalizedString("RESET", comment: "no comment"), style: .destructive) {
            self.gpxTrackingStatus = .notStarted
        }
        
        presentAlert(withTitle: nil,
                     message: NSLocalizedString("SELECT_OPTION", comment: "no comment"),
                     preferredStyle: .actionSheet,
                     actions: [cancelOption, saveAndStartOption, deleteOption])
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
        
        presentAlert(withTitle: NSLocalizedString("LOCATION_SERVICES_DISABLED", comment: "no comment"),
                     message: NSLocalizedString("ENABLE_LOCATION_SERVICES", comment: "no comment"),
                     preferredStyle: .alert, actions: [button])
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
        
        presentAlert(withTitle: NSLocalizedString("ACCESS_TO_LOCATION_DENIED", comment: "no comment"),
                     message: NSLocalizedString("ALLOW_LOCATION", comment: "no comment"),
                     preferredStyle: .alert, actions: [button])
    }

}

// MARK: StopWatchDelegate

///
/// Updates the `timeLabel` with the `stopWatch` elapsedTime.
/// In the main ViewController there is a label that holds the elapsed time, that is, the time that
/// user has been tracking his position.
///
///
extension InterfaceController: StopWatchDelegate {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        timeLabel.setText(elapsedTimeString)
    }
}

// MARK: CLLocationManagerDelegate

extension InterfaceController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error)")
        coordinatesLabel.setText(kNotGettingLocationText)
        signalAccuracyLabel.setText(kUnknownAccuracyText)
        altitudeLabel.setText(kUnknownAltitudeText)
        signalImageView.setImage(signalImage0)
        speedLabel.setText(kUnknownSpeedText)
        //signalAccuracyLabel.text = kUnknownAccuracyText
        //signalImageView.image = signalImage0
        let locationError = error as? CLError
        switch locationError?.code {
        case CLError.locationUnknown:
            print("Location Unknown")
        case CLError.denied:
            print("Access to location services denied. Display message")
            checkLocationServicesStatus()
        case CLError.headingFailure:
            print("Heading failure")
        default:
            print("Default error")
        }
        
    }
    
    ///
    /// Updates location accuracy and map information when user is in a new position
    ///
    ///
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //updates signal image accuracy
        let newLocation = locations.first!
        
        let hAcc = newLocation.horizontalAccuracy
        let vAcc = newLocation.verticalAccuracy
        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(hAcc) vAcc: \(vAcc) floor: \(newLocation.floor?.description ?? "''")")

        signalAccuracyLabel.setText(hAcc.toAccuracy(useImperial: preferences.useImperial))
        if hAcc < kSignalAccuracy6 {
            self.signalImageView.setImage(signalImage6)
        } else if hAcc < kSignalAccuracy5 {
            self.signalImageView.setImage(signalImage5)
        } else if hAcc < kSignalAccuracy4 {
            self.signalImageView.setImage(signalImage4)
        } else if hAcc < kSignalAccuracy3 {
            self.signalImageView.setImage(signalImage3)
        } else if hAcc < kSignalAccuracy2 {
            self.signalImageView.setImage(signalImage2)
        } else if hAcc < kSignalAccuracy1 {
            self.signalImageView.setImage(signalImage1)
        } else {
            self.signalImageView.setImage(signalImage0)
        }
        
        // Update coordsLabels
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        
        coordinatesLabel.setText("\(latFormat),\(lonFormat)")
        altitudeLabel.setText(newLocation.altitude.toAltitude(useImperial: preferences.useImperial))
        
        //Update speed (provided in m/s, but displayed in km/h)
        speedLabel.setText(newLocation.speed.toSpeed(useImperial: preferences.useImperial))
        
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track (\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude))")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel.setText(map.totalTrackedDistance.toDistance(useImperial: preferences.useImperial))
            //currentSegmentDistanceLabel.distance = map.currentSegmentDistance
        }
    }
}
