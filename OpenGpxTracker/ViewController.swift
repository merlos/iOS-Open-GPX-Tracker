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

// Upper limits threshold (in meters) on signal accuracy.
let kSignalAccuracy6 = 6.0
let kSignalAccuracy5 = 11.0
let kSignalAccuracy4 = 31.0
let kSignalAccuracy3 = 51.0
let kSignalAccuracy2 = 101.0
let kSignalAccuracy1 = 201.0


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
                followUserButton.setImage(UIImage(named: "follow_user_high"), forState: .Normal)
                map.setCenterCoordinate((map.userLocation.coordinate), animated: true)
                
            } else {
                print("followUser=false")
               followUserButton.setImage(UIImage(named: "follow_user"), forState: .Normal)
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
    
    var map: GPXMapView
    let mapViewDelegate = MapViewDelegate()
    
    //Status Vars
    var stopWatch = StopWatch()
    var lastGpxFilename: String = ""
    
    var hasWaypoints: Bool = false { // Was any waypoint added to the map?
        didSet {
            if hasWaypoints {
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
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
                trackerButton.setTitle("Start Tracking", forState: .Normal)
                trackerButton.backgroundColor = kGreenButtonBackgroundColor
                //save & reset button to transparent.
                saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
                resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
                //reset clock
                stopWatch.reset()
                timeLabel.text = stopWatch.elapsedTimeString
                
                map.clearMap() //clear map
                lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                totalTrackedDistanceLabel.distance = (map.totalTrackedDistance)
                currentSegmentDistanceLabel.distance = (map.currentSegmentDistance)
                
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
                trackerButton.setTitle("Pause", forState: .Normal)
                trackerButton.backgroundColor = kPurpleButtonBackgroundColor
                //activate save & reset buttons
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
                // start clock
                self.stopWatch.start()
                
            case .Paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle("Resume", forState: .Normal)
                self.trackerButton.backgroundColor = kGreenButtonBackgroundColor
                // activate save & reset (just in case switched from .NotStarted)
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                self.map.startNewTrackSegment()
            }
        }
    }

    //Editing Waypoint Temporal Reference
    var lastLocation: CLLocation? //Last point of current segment.
    
    
    //UI
    //labels
    var appTitleLabel: UILabel
    //var appTitleBackgroundView: UIView
    var signalImageView: UIImageView
    var coordsLabel: UILabel
    var timeLabel: UILabel
    var speedLabel: UILabel
    var totalTrackedDistanceLabel: UIDistanceLabel
    var currentSegmentDistanceLabel: UIDistanceLabel
 
    
    //buttons
    var followUserButton: UIButton
    var newPinButton: UIButton
    var folderButton: UIButton
    var aboutButton: UIButton
    var preferencesButton: UIButton
    var resetButton: UIButton
    var trackerButton: UIButton
    var saveButton: UIButton
    
    //signal accuracy images
    let signalImage0 = UIImage(named: "signal0")
    let signalImage1 = UIImage(named: "signal1")
    let signalImage2 = UIImage(named: "signal2")
    let signalImage3 = UIImage(named: "signal3")
    let signalImage4 = UIImage(named: "signal4")
    let signalImage5 = UIImage(named: "signal5")
    let signalImage6 = UIImage(named: "signal6")
 
    // Initializer. Just initializes the class vars/const
    required init(coder aDecoder: NSCoder) {
        self.map = GPXMapView(coder: aDecoder)!
        
        self.appTitleLabel = UILabel(coder: aDecoder)!
        self.signalImageView = UIImageView(coder: aDecoder)!
        self.coordsLabel = UILabel(coder: aDecoder)!
        
        self.timeLabel = UILabel(coder: aDecoder)!
        self.speedLabel = UILabel(coder: aDecoder)!
        self.totalTrackedDistanceLabel = UIDistanceLabel(coder: aDecoder)!
        self.currentSegmentDistanceLabel = UIDistanceLabel(coder: aDecoder)!
        
        self.followUserButton = UIButton(coder: aDecoder)!
        self.newPinButton = UIButton(coder: aDecoder)!
        self.folderButton = UIButton(coder: aDecoder)!
        self.resetButton = UIButton(coder: aDecoder)!
        self.aboutButton = UIButton(coder: aDecoder)!
        self.preferencesButton = UIButton(coder: aDecoder)!
        
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
        map.delegate = mapViewDelegate
        
        map.showsUserLocation = true
        let mapH: CGFloat = self.view.bounds.size.height - 20.0
        map.frame = CGRect(x: 0.0, y: 20.0, width: self.view.bounds.size.width, height: mapH)
        map.zoomEnabled = true
        map.rotateEnabled = true
        map.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addPinAtTappedLocation(_:)))
        )
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.stopFollowingUser(_:)))
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        //let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture")
        //map.addGestureRecognizer(pinchGesture)
        
        //Set Tile Server
        let defaults = NSUserDefaults.standardUserDefaults()
        if let tileServerInt: Int = defaults.integerForKey("tileServerInt") {
            print("tileServer preference loaded: \(tileServerInt)")
            map.tileServer = GPXTileServer(rawValue: tileServerInt)!
        } else {
            print("using default tileServer: Apple")
            map.tileServer = GPXTileServer.Apple
        }
        
        
        // set default zoom
        let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        // HEADER
        
        //add the app title Label (Branding, branding, branding! )
        let appTitleW: CGFloat = self.view.frame.width//200.0
        let appTitleH: CGFloat = 14.0
        let appTitleX: CGFloat = 0 //self.view.frame.width/2 - appTitleW/2
        let appTitleY: CGFloat = 20
        appTitleLabel.frame = CGRect(x:appTitleX, y: appTitleY, width: appTitleW, height: appTitleH)
        appTitleLabel.text = "  Open GPX Tracker"
        appTitleLabel.textAlignment = .Left
        appTitleLabel.font = UIFont.boldSystemFontOfSize(10)
        //appTitleLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        appTitleLabel.textColor = UIColor.yellowColor()
        appTitleLabel.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        self.view.addSubview(appTitleLabel)
        
        
        // CoordLabel
        coordsLabel.frame = CGRect(x: self.map.frame.width - 305, y: 20, width: 300, height: 12)
        coordsLabel.textAlignment = .Right
        coordsLabel.font = UIFont(name:"DinAlternate-Bold", size: 12.0)
        coordsLabel.textColor = UIColor.whiteColor()
        coordsLabel.text = "Not getting location"
        self.view.addSubview(coordsLabel)
        
        
        // Tracked info
        
        //timeLabel
        timeLabel.frame = CGRect(x: self.map.frame.width - 160, y: 20, width: 150, height: 40)
        timeLabel.textAlignment = .Right
        timeLabel.font = UIFont(name: "DinCondensed-Bold", size:36.0)
        timeLabel.text = "00:00:00"
        //timeLabel.shadowColor = UIColor.whiteColor()
        //timeLabel.shadowOffset = CGSize(width: 1, height: 1)
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(timeLabel)
        
        //speed Label
        speedLabel.frame = CGRect(x: self.map.frame.width - 160,  y: 20 + 36, width: 150, height: 20)
        speedLabel.textAlignment = .Right
        speedLabel.font = UIFont(name: "DinAlternate-Bold", size: 18.0)
        speedLabel.text = "0.00 km/h"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(speedLabel)
        
        //tracked distance
        totalTrackedDistanceLabel.frame = CGRect(x: self.map.frame.width - 160, y: 60 + 20, width: 150, height: 40)
        totalTrackedDistanceLabel.textAlignment = .Right
        totalTrackedDistanceLabel.font = UIFont(name: "DinCondensed-Bold", size: 36.0)
        totalTrackedDistanceLabel.text = "0m"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(totalTrackedDistanceLabel)
        
        currentSegmentDistanceLabel.frame = CGRect(x: self.map.frame.width - 160, y: 80 + 36, width: 150, height: 20)
        currentSegmentDistanceLabel.textAlignment = .Right
        currentSegmentDistanceLabel.font = UIFont(name: "DinAlternate-Bold", size: 18.0)
        currentSegmentDistanceLabel.text = "0m"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(currentSegmentDistanceLabel)
        
        
        //about button
        aboutButton.frame = CGRect(x: 5 + 8, y: 14 + 5 + 48 + 5, width: 32, height: 32)
        aboutButton.setImage(UIImage(named: "info"), forState: UIControlState.Normal)
        aboutButton.setImage(UIImage(named: "info_high"), forState: .Highlighted)
        aboutButton.addTarget(self, action: #selector(ViewController.openAboutViewController), forControlEvents: .TouchUpInside)
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        map.addSubview(aboutButton)
        
        //preferences button
        preferencesButton.frame = CGRect(x: 5 + 10 + 48, y: 14 + 5 + 8, width: 32, height: 32)
        preferencesButton.setImage(UIImage(named: "prefs"), forState: UIControlState.Normal)
        preferencesButton.setImage(UIImage(named: "prefs_high"), forState: .Highlighted)
        preferencesButton.addTarget(self, action: #selector(ViewController.openPreferencesTableViewController), forControlEvents: .TouchUpInside)
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        map.addSubview(preferencesButton)
        
        
        // Folder button
        let folderW: CGFloat = kButtonSmallSize
        let folderH: CGFloat = kButtonSmallSize
        let folderX: CGFloat = folderW/2 + 5
        let folderY: CGFloat = folderH/2 + 5 + 14
        folderButton.frame = CGRect(x: 0, y: 0, width: folderW, height: folderH)
        folderButton.center = CGPoint(x: folderX, y: folderY)
        folderButton.setImage(UIImage(named: "folder"), forState: UIControlState.Normal)
        folderButton.setImage(UIImage(named: "folderHigh"), forState: .Highlighted)
        folderButton.addTarget(self, action: #selector(ViewController.openFolderViewController), forControlEvents: .TouchUpInside)
        folderButton.backgroundColor = kWhiteBackgroundColor
        folderButton.layer.cornerRadius = 24
        map.addSubview(folderButton)
        
        
        
        //
        // Button Bar
        //
        // [ Small ] [ Small ] [ Large     ] [Medium] [ Small] [Small]
        //                     [ (tracker) ]
        //                     [ track     ]
        // [ follow] [ +Pin  ] [ Pause     ] [ Save ] [ Reset] [ folder
        //                     [ Resume    ]
        //
        //                       trackerX
        //                         |
        //                         |
        // [-----------------------|--------------------------]
        //                  map.frame/2 (center)
        
        let yCenterForButtons: CGFloat = map.frame.height - kButtonLargeSize/2 - 5 //center Y of start
        
        
        
        //add signal accuracy images.
        signalImageView.image = signalImage0
        signalImageView.frame = CGRect(x: self.view.frame.width/2 - 25.0, y:  14 + 5, width: 50, height: 30)
        map.addSubview(signalImageView)
        
        
        // Start
        let trackerW: CGFloat = kButtonLargeSize
        let trackerH: CGFloat = kButtonLargeSize
        let trackerX: CGFloat = self.map.frame.width/2 - 0.0 // Center of start
        let trackerY: CGFloat = yCenterForButtons
        trackerButton.frame = CGRect(x: 0, y:0, width: trackerW, height: trackerH)
        trackerButton.center = CGPoint(x: trackerX, y: trackerY)
        trackerButton.layer.cornerRadius = trackerW/2
        trackerButton.setTitle("Start Tracking", forState: .Normal)
        trackerButton.backgroundColor = kGreenButtonBackgroundColor
        trackerButton.addTarget(self, action: #selector(ViewController.trackerButtonTapped), forControlEvents: .TouchUpInside)
        trackerButton.hidden = false
        trackerButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        trackerButton.titleLabel?.numberOfLines = 2
        trackerButton.titleLabel?.textAlignment = .Center
        map.addSubview(trackerButton)
        
        
        // Pin Button (on the left of start)
        let newPinW: CGFloat = kButtonSmallSize
        let newPinH: CGFloat = kButtonSmallSize
        let newPinX: CGFloat = trackerX - trackerW/2 - kButtonSeparation - newPinW/2
        let newPinY: CGFloat = yCenterForButtons
        newPinButton.frame = CGRect(x: 0, y: 0, width: newPinW, height: newPinH)
        newPinButton.center = CGPoint(x: newPinX, y: newPinY)
        newPinButton.layer.cornerRadius = newPinW/2
        newPinButton.backgroundColor = kWhiteBackgroundColor
        newPinButton.setImage(UIImage(named: "addPin"), forState: UIControlState.Normal)
        newPinButton.setImage(UIImage(named: "addPinHigh"), forState: .Highlighted)
        newPinButton.addTarget(self, action: #selector(ViewController.addPinAtMyLocation), forControlEvents: .TouchUpInside)
        //let newPinLongPress = UILongPressGestureRecognizer(target: self, action: Selector("newPinLongPress:"))
        //newPinButton.addGestureRecognizer(newPinLongPress)
        map.addSubview(newPinButton)
        
        // Follow user button
        let followW: CGFloat = kButtonSmallSize
        let followH: CGFloat = kButtonSmallSize
        let followX: CGFloat = newPinX - newPinW/2 - kButtonSeparation - followW/2
        let followY: CGFloat = yCenterForButtons
        followUserButton.frame = CGRect(x: 0, y: 0, width: followW, height: followH)
        followUserButton.center = CGPointMake(followX, followY)
        followUserButton.layer.cornerRadius = followW/2
        followUserButton.backgroundColor = kWhiteBackgroundColor
        //follow_user_high represents the user is being followed. Default status when app starts
        followUserButton.setImage(UIImage(named: "follow_user_high"), forState: UIControlState.Normal)
        followUserButton.setImage(UIImage(named: "follow_user_high"), forState: .Highlighted)
        followUserButton.addTarget(self, action: #selector(ViewController.followButtonTroggler), forControlEvents: .TouchUpInside)
        map.addSubview(followUserButton)
        
        // Save button
        let saveW: CGFloat = kButtonSmallSize
        let saveH: CGFloat = kButtonSmallSize
        let saveX: CGFloat = trackerX + trackerW/2 + kButtonSeparation + saveW/2
        let saveY: CGFloat = yCenterForButtons
        saveButton.frame = CGRect(x: 0, y: 0, width: saveW, height: saveH)
        saveButton.center = CGPoint(x: saveX, y: saveY)
        saveButton.layer.cornerRadius = saveW/2
        saveButton.setTitle("Save", forState: .Normal)
        saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
        saveButton.addTarget(self, action: #selector(ViewController.saveButtonTapped), forControlEvents: .TouchUpInside)
        saveButton.hidden = false
        saveButton.titleLabel?.textAlignment = .Center
        map.addSubview(saveButton)
        
        // Reset button
        let resetW: CGFloat = kButtonSmallSize
        let resetH: CGFloat = kButtonSmallSize
        let resetX: CGFloat = saveX + saveW/2 + kButtonSeparation + resetW/2
        let resetY: CGFloat = yCenterForButtons
        resetButton.frame = CGRect(x: 0, y: 0, width: resetW, height: resetH)
        resetButton.center = CGPoint(x: resetX, y: resetY)
        resetButton.layer.cornerRadius = resetW/2
        resetButton.setTitle("Reset", forState: .Normal)
        resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
        resetButton.addTarget(self, action: #selector(ViewController.resetButtonTapped), forControlEvents: .TouchUpInside)
        resetButton.hidden = false
        resetButton.titleLabel?.textAlignment = .Center
        map.addSubview(resetButton)
        
        addNotificationObservers()
    }
    /*
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
        
        appTitleBackgroundView.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        coordsLabel.font = font3
        timeLabel.font = font1
        speedLabel.font = font2
        totalTrackedDistanceLabel.font = font1
        currentSegmentDistanceLabel.font = font2
    }
    
    func setupTrackerButtons() {
        
        trackerButton.backgroundColor = kGreenButtonBackgroundColor
        trackerButton.titleLabel?.numberOfLines = 2
        trackerButton.titleLabel?.textAlignment = .Center
        
        saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
        resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
    }
    */
    
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
    
    func openFolderViewController() {
        print("openFolderViewController")
        let vc = GPXFilesTableViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true) { () -> Void in }
    }
    
    
    func openAboutViewController() {
        let vc = AboutViewController(nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true) { () -> Void in }
    }
    
    func openPreferencesTableViewController() {
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
            map.addWaypointAtViewPoint(point)
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
    
    func addPinAtMyLocation() {
        print("Adding Pin at my location")
        let waypoint = GPXWaypoint(coordinate: map.userLocation.coordinate)
        map.addWaypoint(waypoint)
        self.hasWaypoints = true
    }
    
    
    func followButtonTroggler() {
        self.followUser = !self.followUser
    }
    
    
    func resetButtonTapped() {
        //clear tracks, pins and overlays if not already in that status
        if self.gpxTrackingStatus != .NotStarted {
            self.gpxTrackingStatus = .NotStarted
        }
    }
    
    ////////////////////////////
    // TRACKING USER
    
    func trackerButtonTapped() {
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
    
    
    func saveButtonTapped() {
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
                let gpxString = self.map.exportToGPXString()
                GPXFileManager.save(filename!, gpxContents: gpxString)
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
        let hAcc = newLocation.horizontalAccuracy
        if hAcc < kSignalAccuracy6 {
            self.signalImageView.image = signalImage6
        } else if hAcc < kSignalAccuracy5 {
            self.signalImageView.image = signalImage5
        } else if hAcc < kSignalAccuracy4 {
            self.signalImageView.image = signalImage4
        } else if hAcc < kSignalAccuracy3 {
            self.signalImageView.image = signalImage3
        } else if hAcc < kSignalAccuracy2 {
            self.signalImageView.image = signalImage2
        } else if hAcc < kSignalAccuracy1 {
            self.signalImageView.image = signalImage1
        } else{
            self.signalImageView.image = signalImage0
        }
        

        
        //Update coordsLabel
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        coordsLabel.text = "\(latFormat),\(lonFormat)"
        
        //Update speed (provided in m/s, but displayed in km/h)
        var speedFormat: String
        if newLocation.speed < 0 {
            speedFormat = "?.??"
        } else {
            speedFormat = String(format: "%.2f", (newLocation.speed * 3.6))
        }
        speedLabel.text = "\(speedFormat) km/h"
        
        //Update Map center and track overlay if user is being followed
        if followUser {
            map.setCenterCoordinate(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .Tracking {
            print("didUpdateLocation: adding point to track \(newLocation.coordinate)")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel.distance = map.totalTrackedDistance
            currentSegmentDistanceLabel.distance = map.currentSegmentDistance
        }
        
    }
    
    //PreferencesTableViewController Delegate 
    func didUpdateTileServer(newGpxTileServer: Int) {
        print("didUpdateTileServer: \(newGpxTileServer)")
        self.map.tileServer = GPXTileServer(rawValue: newGpxTileServer)!
        
    }
    
    //GPXFilesTableViewController Delegate
    func didLoadGPXFileWithName(gpxFilename: String, gpxRoot: GPXRoot) {
        //println("Loaded GPX file", gpx.gpx())
        self.lastGpxFilename = gpxFilename
        //emulate a reset button tap
        self.resetButtonTapped()
        //force reset timer just in case reset does not do it
        self.stopWatch.reset()
        //load data
        self.map.importFromGPXRoot(gpxRoot)
        //stop following user
        self.followUser = false
        //center map in GPX data
        self.map.regionToGPXExtent()
        self.gpxTrackingStatus = .Paused
        
        self.totalTrackedDistanceLabel.distance = self.map.totalTrackedDistance
        
    }
    
    // StopWatchDelegate
    func stopWatch(stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        timeLabel.text = elapsedTimeString
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
