//
//  ViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 13/09/14.
//  Copyright (c) 2014 TransitBox. All rights reserved.
//

import UIKit

import CoreLocation
import MapKit

//Accuracy levels
//  kBadSignalAccuracy would be greate than mediumSignal accuracy
let kMediumSignalAccuracy = 100.0
let kGoodSignalAccuracy = 20.0

//Accesory View buttons tags
let kDeleteWaypointAccesoryButtonTag = 666
let kEditWaypointAccesoryButtonTag = 333

let kButtonSmallSize: CGFloat = 48.0
let kButtonLargeSize: CGFloat = 96.0
let kButtonSeparation: CGFloat = 6.0

class ViewController: UIViewController,
                        UIGestureRecognizerDelegate,
                        GPXFilesTableViewControllerDelegate,
                        PreferencesTableViewControllerDelegate,
                        StopWatchDelegate,
                        TrackRecorderDelegate {
    
    var followUser: Bool = true {
        didSet {
            if followUser {
                print("followUser=true")
                followUserButton?.setImage(UIImage(named: "follow_user_high"), forState: .Normal)
                map?.setCenterCoordinate((map?.userLocation.coordinate)!, animated: true)
            } else {
                print("followUser=false")
               followUserButton?.setImage(UIImage(named: "follow_user"), forState: .Normal)
            }
        }
    }
    
    //MapView
    let trackRecorder = TrackRecorder()
    
    @IBOutlet var map: GPXMapView?
    let mapViewDelegate = MapViewDelegate()
    
    //Status Vars
    var stopWatch = StopWatch()
    var lastGpxFilename: String = ""
    
    var hasWaypoints: Bool = false { // Was any waypoint added to the map?
        didSet {
            if hasWaypoints {
                saveButton?.backgroundColor = kBlueButtonBackgroundColor
                resetButton?.backgroundColor = kRedButtonBackgroundColor
            }
        }
    }
    
    enum GpxTrackingStatus {
        case NotStarted
        case Tracking
        case Paused
    }
    var gpxTrackingStatus: GpxTrackingStatus = GpxTrackingStatus.NotStarted {
        didSet {
            print("gpxTrackingStatus changed to \(gpxTrackingStatus)")
            switch gpxTrackingStatus {
            case .NotStarted:
                print("switched to non started")
                // set Tracker button to allow Start 
                trackerButton?.setTitle("Start Tracking", forState: .Normal)
                trackerButton?.backgroundColor = kGreenButtonBackgroundColor
                //save & reset button to transparent.
                saveButton?.backgroundColor = kDisabledBlueButtonBackgroundColor
                resetButton?.backgroundColor = kDisabledRedButtonBackgroundColor
                //reset clock
                stopWatch.reset()
                timeLabel?.text = stopWatch.elapsedTimeString
                
                map?.clearMap() //clear map
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                totalTrackedDistanceLabel?.distance = (map?.totalTrackedDistance)!
                currentSegmentDistanceLabel?.distance = (map?.currentSegmentDistance)!
                
            case .Tracking:
                print("switched to tracking mode")
                // set tracerkButton to allow Pause
                trackerButton?.setTitle("Pause", forState: .Normal)
                trackerButton?.backgroundColor = kPurpleButtonBackgroundColor
                //activate save & reset buttons
                saveButton?.backgroundColor = kBlueButtonBackgroundColor
                resetButton?.backgroundColor = kRedButtonBackgroundColor
                // start clock
                self.stopWatch.start()
                
            case .Paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton?.setTitle("Resume", forState: .Normal)
                self.trackerButton?.backgroundColor = kGreenButtonBackgroundColor
                // activate save & reset (just in case switched from .NotStarted)
                saveButton?.backgroundColor = kBlueButtonBackgroundColor
                resetButton?.backgroundColor = kRedButtonBackgroundColor
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                self.map?.startNewTrackSegment()
            }
        }
    }
    
    // MARK: Outlets
    @IBOutlet var appTitleLabel: UILabel?
    @IBOutlet var appTitleBackgroundView: UIView?
    @IBOutlet var signalImageView: UIImageView?
    @IBOutlet var coordsLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var speedLabel: UILabel?
    @IBOutlet var totalTrackedDistanceLabel: UIDistanceLabel?
    @IBOutlet var currentSegmentDistanceLabel: UIDistanceLabel?
 
    @IBOutlet var followUserButton: UIButton?
    @IBOutlet var newPinButton: UIButton?
    @IBOutlet var folderButton: UIButton?
    @IBOutlet var aboutButton: UIButton?
    @IBOutlet var preferencesButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    @IBOutlet var trackerButton: UIButton?
    @IBOutlet var saveButton: UIButton?
    
    let badSignalImage = UIImage(named: "1")
    let midSignalImage = UIImage(named: "2")
    let goodSignalImage = UIImage(named: "3")
   
    deinit {
        removeNotificationObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopWatch.delegate = self
        
        // Map configuration Stuff
        map?.delegate = mapViewDelegate
        trackRecorder.delegate = self

        map?.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: "addPinAtTappedLocation:")
        )
        let panGesture = UIPanGestureRecognizer(target: self, action: "stopFollowingUser:")
        panGesture.delegate = self
        map?.addGestureRecognizer(panGesture)
       
        //Set Tile Server
        let defaults = NSUserDefaults.standardUserDefaults()
        if let tileServerInt: Int = defaults.integerForKey("tileServerInt") {
            print("tileServer preference loaded: \(tileServerInt)")
            map?.tileServer = GPXTileServer(rawValue: tileServerInt)!
        } else {
            print("using default tileServer: Apple")
            map?.tileServer = GPXTileServer.Apple
        }
        
        map?.centerAtCoordinate(trackRecorder.currentCoordinate)
        
        setupFonts()
        setupTrackerButtons()
        addNotificationObservers()
    }
    
    func setupFonts() {
        appTitleBackgroundView?.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        coordsLabel?.font = font3
        timeLabel?.font = font1
        speedLabel?.font = font2
        totalTrackedDistanceLabel?.font = font1
        currentSegmentDistanceLabel?.font = font2
    }
    
    func setupTrackerButtons() {
        trackerButton?.backgroundColor = kGreenButtonBackgroundColor
        trackerButton?.titleLabel?.numberOfLines = 2
        trackerButton?.titleLabel?.textAlignment = .Center
        saveButton?.backgroundColor = kDisabledBlueButtonBackgroundColor
        resetButton?.backgroundColor = kDisabledRedButtonBackgroundColor
    }
    
    // MARK: Notifications
    func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackground",
            name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func didEnterBackground() {
        if gpxTrackingStatus != .Tracking {
            trackRecorder.stop()
        }
    }
    
    // MARK: Actions
    
    @IBAction func openFolderViewController(sender: AnyObject) {
        print("openFolderViewController")
        let vc = GPXFilesTableViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true) { () -> Void in }
    }
    
    @IBAction func openAboutViewController(sender: AnyObject) {
        let vc = AboutViewController(nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true) { () -> Void in }
    }
    
    @IBAction func openPreferencesTableViewController(sender: AnyObject) {
        print("openPreferencesTableViewController")
        let vc = PreferencesTableViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true) { () -> Void in }
    }
    
    func stopFollowingUser(gesture: UIPanGestureRecognizer) {
        if self.followUser {
            self.followUser = false
        }
    }
    
    // UIGestureRecognizerDelegate required for stopFollowingUser
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addPinAtTappedLocation(gesture: UILongPressGestureRecognizer) {
        if  gesture.state == UIGestureRecognizerState.Began {
            print("Adding Pin map Long Press Gesture")
            let point: CGPoint = gesture.locationInView(self.map)
            map?.addWaypointAtViewPoint(point)
            //Allows save and reset
            self.hasWaypoints = true
        }
    }
    
    @IBAction func addPinAtMyLocation(sender: AnyObject) {
        print("Adding Pin at my location")
        let waypoint = GPXWaypoint(coordinate: (map?.userLocation.coordinate)!)
        map?.addWaypoint(waypoint)
        self.hasWaypoints = true
    }
    
    @IBAction func followButtonTroggler(sender: AnyObject) {
        self.followUser = !self.followUser
    }
    
    @IBAction func resetButtonTapped(sender: AnyObject?) {
        //clear tracks, pins and overlays if not already in that status
        if self.gpxTrackingStatus != .NotStarted {
            self.gpxTrackingStatus = .NotStarted
        }
    }
    
    // MARK: TRACKING USER
    @IBAction func trackerButtonTapped(sender: AnyObject) {
        print("startGpxTracking::")
        switch gpxTrackingStatus {
        case .NotStarted:
            gpxTrackingStatus = .Tracking
        case .Tracking:
            gpxTrackingStatus = .Paused
        case .Paused:
            //set to tracking
            gpxTrackingStatus = .Tracking
        }
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .NotStarted) && !self.hasWaypoints {
            return
        }
        
        let alertController = UIAlertController(title: "Save as", message: "Enter GPX session name",
            preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.text = self.lastGpxFilename
        }
        
        let okAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction) -> Void in
            guard let textField = alertController.textFields?.first else {
                return
            }
            
            let filename = (textField.text!.utf16.count == 0) ? " " : textField.text
            if let gpxString = self.map?.exportToGPXString() {
                GPXFileManager.save(filename!, gpxContents: gpxString)
            }
            self.lastGpxFilename = filename!

            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action: UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
    }
    
    //PreferencesTableViewController Delegate
    func didUpdateTileServer(newGpxTileServer: Int) {
        print("didUpdateTileServer: \(newGpxTileServer)")
        self.map?.tileServer = GPXTileServer(rawValue: newGpxTileServer)!
        
    }
    
    //GPXFilesTableViewController Delegate
    func didLoadGPXFileWithName(gpxFilename: String, gpxRoot: GPXRoot) {
        //println("Loaded GPX file", gpx.gpx())
        self.lastGpxFilename = gpxFilename
        //emulate a reset button tap
        self.resetButtonTapped(resetButton)
        //force reset timer just in case reset does not do it
        self.stopWatch.reset()
        //load data
        self.map?.importFromGPXRoot(gpxRoot)
        //stop following user
        self.followUser = false
        //center map in GPX data
        self.map?.regionToGPXExtent()
        self.gpxTrackingStatus = .Paused
        
        self.totalTrackedDistanceLabel?.distance = (self.map?.totalTrackedDistance)!
    }
    
    // StopWatchDelegate
    func stopWatch(stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        timeLabel?.text = elapsedTimeString
    }
    
    func trackRecorder(recorder: TrackRecorder, didUpdateToLocation newLocation: CLLocation) {
        if newLocation.horizontalAccuracy < kMediumSignalAccuracy {
            self.signalImageView?.image = midSignalImage
        } else {
            self.signalImageView?.image = badSignalImage
        }
        if newLocation.horizontalAccuracy < kGoodSignalAccuracy {
            self.signalImageView?.image = goodSignalImage
        }
        
        //Update coordsLabel
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        coordsLabel?.text = "\(latFormat),\(lonFormat)"
        
        //Update speed (provided in m/s, but displayed in km/h)
        var speedFormat: String
        if newLocation.speed < 0 {
            speedFormat = "?.??"
        } else {
            speedFormat = String(format: "%.2f", (newLocation.speed * 3.6))
        }
        speedLabel?.text = "\(speedFormat) km/h"
        
        //Update Map center and track overlay if user is being followed
        if followUser {
            map?.setCenterCoordinate(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .Tracking {
            print("didUpdateLocation: adding point to track \(newLocation.coordinate)")
            map?.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel?.distance = (map?.totalTrackedDistance)!
            currentSegmentDistanceLabel?.distance = (map?.currentSegmentDistance)!
        }
    }
}
