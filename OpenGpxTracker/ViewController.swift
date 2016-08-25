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

//AlertViews tags
let kEditWaypointAlertViewTag = 33
let kSaveSessionAlertViewTag = 88

let kButtonSmallSize: CGFloat = 48.0
let kButtonLargeSize: CGFloat = 96.0
let kButtonSeparation: CGFloat = 6.0


class ViewController: UIViewController,
                        CLLocationManagerDelegate,
                        UIGestureRecognizerDelegate,
                        UIAlertViewDelegate,
                        GPXFilesTableViewControllerDelegate,
                        PreferencesTableViewControllerDelegate,
                        StopWatchDelegate {
    
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
    var followUserBeforePinchGesture = true
    
    
    //MapView
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2
        manager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        return manager
    }()
    
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
                
                /*
                // XXX Left here for reference
                UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                    self.trackerButton.hidden = true
                    self.pauseButton.hidden = false
                    }, completion: {(f: Bool) -> Void in
                        println("finished animation start tracking")
                })
                */
                
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

    //Editing Waypoint Temporal Reference
    var lastLocation: CLLocation? //Last point of current segment.
    
    
    //UI
    //labels
    @IBOutlet var appTitleLabel: UILabel?
    @IBOutlet var appTitleBackgroundView: UIView?
    @IBOutlet var signalImageView: UIImageView?
    @IBOutlet var coordsLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var speedLabel: UILabel?
    @IBOutlet var totalTrackedDistanceLabel: UIDistanceLabel?
    @IBOutlet var currentSegmentDistanceLabel: UIDistanceLabel?
 
    
    //buttons
    @IBOutlet var followUserButton: UIButton?
    @IBOutlet var newPinButton: UIButton?
    @IBOutlet var folderButton: UIButton?
    @IBOutlet var aboutButton: UIButton?
    @IBOutlet var preferencesButton: UIButton?
    @IBOutlet var resetButton: UIButton?
    @IBOutlet var trackerButton: UIButton?
    @IBOutlet var saveButton: UIButton?
    
    
    let SignalImage0 = UIImage(named: "signal0")
    let SignalImage1 = UIImage(named: "signal1")
    let SignalImage2 = UIImage(named: "signal2")
    let SignalImage3 = UIImage(named: "signal3")
    let SignalImage4 = UIImage(named: "signal4")
    let SignalImage5 = UIImage(named: "signal5")
    let SignalImage6 = UIImage(named: "signal6")
 
    // Initializer. Just initializes the class vars/const
    required init(coder aDecoder: NSCoder) {
    
        self.currentSegmentDistanceLabel = UIDistanceLabel(coder: aDecoder)!
        
        self.followUserButton = UIButton(coder: aDecoder)!
        self.newPinButton = UIButton(coder: aDecoder)!
        self.resetButton = UIButton(coder: aDecoder)!
        
        self.trackerButton = UIButton(coder: aDecoder)!
        self.saveButton = UIButton(coder: aDecoder)!
        
        super.init(coder: aDecoder)!
        followUser = true
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopWatch.delegate = self
        
        // Map configuration Stuff
        map?.delegate = mapViewDelegate

        let mapH: CGFloat = self.view.bounds.size.height - 20.0
        map?.frame = CGRect(x: 0.0, y: 20.0, width: self.view.bounds.size.width, height: mapH)
        map?.zoomEnabled = true
        map?.rotateEnabled = true
        map?.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addPinAtTappedLocation(_:)))
        )
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.stopFollowingUser(_:)))
        panGesture.delegate = self
        map?.addGestureRecognizer(panGesture)
       
        locationManager.delegate = self
        locationManager.startUpdatingLocation()

        //let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture")
        //map?.addGestureRecognizer(pinchGesture)
        
        //Set Tile Server
        let defaults = NSUserDefaults.standardUserDefaults()
        if let tileServerInt: Int = defaults.integerForKey("tileServerInt") {
            print("tileServer preference loaded: \(tileServerInt)")
            map?.tileServer = GPXTileServer(rawValue: tileServerInt)!
        } else {
            print("using default tileServer: Apple")
            map?.tileServer = GPXTileServer.Apple
        }
        
        
        // set default zoom
//        setDefaultMapZoom()
        let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        map?.setRegion(region, animated: true)
        
        setupFonts()
        setupTrackerButtons()
        
        addNotificationObservers()
    }
    
    func setupFonts() {
        let font1 = UIFont(name: "DinCondensed-Bold", size: 36.0)
        let font2 = UIFont(name: "DinAlternate-Bold", size: 18.0)
        let font3 = UIFont(name: "DinAlternate-Bold", size: 12.0)
        
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
    
    func addNotificationObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.didEnterBackground),
            name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }

    func removeNotificationObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Notifications
    
    func didEnterBackground() {
        if gpxTrackingStatus != .Tracking {
            locationManager.stopUpdatingLocation()
        }
    }
    
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
    
    // zoom gesture controls that follow user to
    func pinchGesture(gesture: UIPinchGestureRecognizer) {
        print("pinchGesture")
     /*   if gesture.state == UIGestureRecognizerState.Began {
            self.followUserBeforePinchGesture = self.followUser
            self.followUser = false
        }
        //return to back
        if gesture.state == UIGestureRecognizerState.Ended {
            self.followUser = self.followUserBeforePinchGesture
        }
        */
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
    
    ////////////////////////////
    // TRACKING USER
    
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
        
        let alert = UIAlertView(title: "Save as", message: "Enter GPX session name", delegate: self, cancelButtonTitle: "Continue tracking")
        
        alert.addButtonWithTitle("Save")
        alert.alertViewStyle = .PlainTextInput
        alert.tag = kSaveSessionAlertViewTag
        alert.show()
        alert.textFieldAtIndex(0)?.text = lastGpxFilename
        //alert.textFieldAtIndex(0)?.selectAll(self)
    }
    
    
    //UIAlertView Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        switch alertView.tag {
        case kSaveSessionAlertViewTag:
            
            print("alertViewDelegate for Save Session")
            
            switch buttonIndex {
            case 0: //cancel
                print("Save canceled")
                
            case 1: //Save
                let filename = (alertView.textFieldAtIndex(0)?.text!.utf16.count == 0) ? " " : alertView.textFieldAtIndex(0)?.text
                print("Save File \(filename)")
                //export to a file
                if let gpxString = self.map?.exportToGPXString() {
                    GPXFileManager.save(filename!, gpxContents: gpxString)
                }
                //println(gpx.gpx())
                self.lastGpxFilename = filename!
                
            default:
            print("[ERROR] it seems there are more than two buttons on the alertview.")
        
            } //buttonIndex
        default:
            print("[ERROR] it seems that the AlertView is not handled properly." )
            
        }
    }
    
    
    //#pragma mark - location manager Delegate
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
         print("didFailWithError\(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        //print("didUpdateToLocation \(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude),",
        //    "Hacc: \(newLocation.horizontalAccuracy), Vacc: \(newLocation.verticalAccuracy)")
      
        //updates signal image accuracy
        var hAcc = newLocation.horizontalAccuracy
        if hAcc < 6 {
            self.signalImageView?.image = SignalImage6
        } else if hAcc < 11 {
            self.signalImageView?.image = SignalImage5
        } else if hAcc < 31 {
            self.signalImageView?.image = SignalImage4
        } else if hAcc < 51 {
            self.signalImageView?.image = SignalImage3
        } else if hAcc < 101 {
            self.signalImageView?.image = SignalImage2
        } else if hAcc < 201 {
            self.signalImageView?.image = SignalImage1
        } else{
            self.signalImageView?.image = SignalImage0
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
