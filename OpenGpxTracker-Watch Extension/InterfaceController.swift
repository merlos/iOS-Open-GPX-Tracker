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

    @IBOutlet var newPinButton: WKInterfaceButton!
    @IBOutlet var trackerButton: WKInterfaceButton!
    @IBOutlet var saveButton: WKInterfaceButton!
    @IBOutlet var resetButton: WKInterfaceButton!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    @IBOutlet var totalTrackedDistanceLabel: WKInterfaceLabel!
    @IBOutlet var signalImageView: WKInterfaceImage!
    @IBOutlet var signalAccuracyLabel: WKInterfaceLabel!
    @IBOutlet var latitudeLabel: WKInterfaceLabel!
    @IBOutlet var longitudeLabel: WKInterfaceLabel!
    @IBOutlet var elevationLabel: WKInterfaceLabel!
    @IBOutlet var speedLabel: WKInterfaceLabel!
    
    
    // Location Manager
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2 //meters
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    
    /// Map View
    let map = GPXMapView() // not even a map view. Considering renaming
    let distanceFormatter = DistanceFormatter()

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
                trackerButton.setTitle("Start Tracking")
                trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
                //save & reset button to transparent.
                saveButton.setBackgroundColor(kDisabledBlueButtonBackgroundColor)
                resetButton.setBackgroundColor(kDisabledRedButtonBackgroundColor)
                //reset clock
                stopWatch.reset()
                timeLabel.setText(stopWatch.elapsedTimeString)
                
                map.clearMap() //clear map
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                distanceFormatter.distance = map.totalTrackedDistance
                totalTrackedDistanceLabel.setText(distanceFormatter.formattedText)
                
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
                // start new track segment
                self.map.startNewTrackSegment()
            }
        }
    }
    
    /// Editing Waypoint Temporal Reference
    var lastLocation: CLLocation? //Last point of current segment.
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if gpxTrackingStatus == .notStarted {
            trackerButton.setBackgroundColor(kGreenButtonBackgroundColor)
            newPinButton.setBackgroundColor(kWhiteBackgroundColor)
            saveButton.setBackgroundColor(kDisabledRedButtonBackgroundColor)
            resetButton.setBackgroundColor(kDisabledBlueButtonBackgroundColor)
            
            latitudeLabel.setText(kNotGettingLocationText)
            longitudeLabel.setText(kNotGettingLocationText)
            signalAccuracyLabel.setText(kUnknownAccuracyText)
            elevationLabel.setText("0.00 m")
            speedLabel.setText("0.00 km/h")
        }
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setTitle("GPX Tracker")
        
        stopWatch.delegate = self
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
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
        print("Adding Pin at my location")
        if let currentCoordinates = locationManager.location?.coordinate {
            let waypoint = GPXWaypoint(coordinate: currentCoordinates)
            map.addWaypoint(waypoint)
            self.hasWaypoints = true
        }
        
    }
    @IBAction func saveButtonTapped() {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) && !self.hasWaypoints {
            return
        }
        let filename = defaultFilename()
        let gpxString = self.map.exportToGPXString()
        GPXFileManager.save(filename, gpxContents: gpxString)
        self.lastGpxFilename = filename
        print(gpxString)
        
        let action = WKAlertAction(title: "Done", style: .default) {}
        presentAlert(withTitle: "GPX file saved", message: "Current session saved as \(filename).gpx ", preferredStyle: .alert, actions: [action])
        
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
        latitudeLabel.setText(kNotGettingLocationText)
        longitudeLabel.setText(kNotGettingLocationText)
        signalAccuracyLabel.setText(kUnknownAccuracyText)
        elevationLabel.setText("0.00 m")
        signalImageView.setImage(signalImage0)
        speedLabel.setText("0.00 km/h")
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
        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(newLocation.horizontalAccuracy) vAcc: \(newLocation.verticalAccuracy) floor: \(newLocation.floor?.description ?? "''")")
        
        let hAcc = newLocation.horizontalAccuracy

        signalAccuracyLabel.setText("±\(hAcc)m")
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
        } else{
            self.signalImageView.setImage(signalImage0)
        }
        
        // Update coordsLabels
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        let altFormat = String(format: "%.2f", newLocation.altitude)
        
        latitudeLabel.setText(latFormat)
        longitudeLabel.setText(lonFormat)
        elevationLabel.setText("\(altFormat) m")
        
        //Update speed (provided in m/s, but displayed in km/h)
        var speedFormat: String
        if newLocation.speed < 0 {
            speedFormat = kUnknownSpeedText
        } else {
            speedFormat = String(format: "%.2f", (newLocation.speed * 3.6))
        }
        speedLabel.setText("\(speedFormat) km/h")
        
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track (\(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude))")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            
            distanceFormatter.distance = map.totalTrackedDistance
            totalTrackedDistanceLabel.setText(distanceFormatter.formattedText)
            //currentSegmentDistanceLabel.distance = map.currentSegmentDistance
        }
    }
    
}

