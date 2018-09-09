//
//  ViewController.swift
//  OpenGpxTracker
//
//  Created by merlos on 13/09/14.
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

let kNotGettingLocationText = "Not getting location"
let kUnknownAccuracyText = "±···m"
let kUnknownSpeedText = "·.··"

let kEditWaypointAlertViewTag = 33
let kSaveSessionAlertViewTag = 88

/// Size for small buttons
let  kButtonSmallSize: CGFloat = 48.0
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
/// Main View Controller of the Application. It is loaded when the application is launched
///
/// Displays a map and a set the buttons to control the tracking
///
///
class ViewController: UIViewController, UIGestureRecognizerDelegate  {
    
    /// Shall the map be centered on current user position?
    /// If yes, whenever the user moves, the center of the map too.
    var followUser: Bool = true {
        didSet {
            if followUser {
                print("followUser=true")
                followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControlState())
                map.setCenter((map.userLocation.coordinate), animated: true)
                
            } else {
                print("followUser=false")
               followUserButton.setImage(UIImage(named: "follow_user"), for: UIControlState())
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
    
    /// Map View
    var map: GPXMapView
    
    /// Map View delegate 
    let mapViewDelegate = MapViewDelegate()
    
    //Status Vars
    var stopWatch = StopWatch()
    var lastGpxFilename: String = ""
    
    /// Has the map any waypoint?
    var hasWaypoints: Bool = false {
        /// Whenever it is updated, if it has waypoints it sets the save and reset button
        didSet {
            if hasWaypoints {
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
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
                trackerButton.setTitle("Start Tracking", for: UIControlState())
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
                
            case .tracking:
                print("switched to tracking mode")
                // set tracerkButton to allow Pause
                trackerButton.setTitle("Pause", for: UIControlState())
                trackerButton.backgroundColor = kPurpleButtonBackgroundColor
                //activate save & reset buttons
                saveButton.backgroundColor = kBlueButtonBackgroundColor
                resetButton.backgroundColor = kRedButtonBackgroundColor
                // start clock
                self.stopWatch.start()
                
            case .paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle("Resume", for: UIControlState())
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

    /// Editing Waypoint Temporal Reference
    var lastLocation: CLLocation? //Last point of current segment.
    
    
    //UI
    //labels
    var appTitleLabel: UILabel
    //var appTitleBackgroundView: UIView
    var signalImageView: UIImageView
    var signalAccuracyLabel: UILabel
    var coordsLabel: UILabel
    var timeLabel: UILabel
    var speedLabel: UILabel
    var totalTrackedDistanceLabel: UIDistanceLabel
    var currentSegmentDistanceLabel: UIDistanceLabel
 
    
    // Buttons
    var followUserButton: UIButton
    var newPinButton: UIButton
    var folderButton: UIButton
    var aboutButton: UIButton
    var preferencesButton: UIButton
    var resetButton: UIButton
    var trackerButton: UIButton
    var saveButton: UIButton
    
    // Signal accuracy images
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
        self.signalAccuracyLabel = UILabel(coder: aDecoder)!
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
    
    ///
    /// De initalize the ViewController.
    ///
    /// Current implementation removes notification observers
    ///
    deinit {
        print("*** deinit")
        removeNotificationObservers()
    }
   
    
    ///
    /// Initializes the view. It adds the UI elements to the view.
    ///
    /// All the UI is built programatically on this method. Interface builder is not used.
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        stopWatch.delegate = self
        
        //Because of the edges, iPhone X is slightly different on the layout.
        //So, Is the current device an iPhone X?
        var isIPhoneX = false
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height == 2436 {
                print("iPhone X detected Bazinga!")
                isIPhoneX = true
            }
        }
        
        // Map configuration Stuff
        map.delegate = mapViewDelegate
        map.showsUserLocation = true
        let mapH: CGFloat = self.view.bounds.size.height - (isIPhoneX ? 0.0 : 20.0)
        map.frame = CGRect(x: 0.0, y: (isIPhoneX ? 0.0 : 20.0), width: self.view.bounds.size.width, height: mapH)
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        
        //If user long presses the map, it will add a Pin (waypoint) at that point
        map.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addPinAtTappedLocation(_:)))
        )
        
        //Each time user pans, if the map is following the user, it stops doing that.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.stopFollowingUser(_:)))
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        //let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture")
        //map.addGestureRecognizer(pinchGesture)
        
        //Preferences load
        let defaults = UserDefaults.standard
        if var tileServerInt = defaults.object(forKey: kDefaultsKeyTileServerInt) as? Int {
            // In version 1.5 one tileServer was removed, so some users may have selected a tileServer that no longer exists.
            tileServerInt = (tileServerInt >= GPXTileServer.count ? GPXTileServer.apple.rawValue : tileServerInt)
            print("** Preferences : setting saved tileServer \(tileServerInt)")
            map.tileServer = GPXTileServer(rawValue: tileServerInt)!
        } else {
            print("** Preferences: using default tileServer: Apple")
            map.tileServer = .apple
        }
        if let useCacheBool = defaults.object(forKey: kDefaultsKeyUseCache) as? Bool {
            print("** Preferences: setting saved useCache: \(useCacheBool)")
            map.useCache = useCacheBool
        }
        
        // Set default zoom
        let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: center, span: span)
        map.setRegion(region, animated: true)
        self.view.addSubview(map)
        
        addNotificationObservers()
        
        //
        // ---------------------- Build Interface Area -----------------------------
        //
        // HEADER
        let font36 = UIFont(name: "DinCondensed-Bold", size: 36.0)
        let font18 = UIFont(name: "DinAlternate-Bold", size: 18.0)
        let font12 = UIFont(name: "DinAlternate-Bold", size: 12.0)
        let font8 = UIFont(name: "DinAlternate-Bold", size: 8.0)
        
        //add the app title Label (Branding, branding, branding! )
        let appTitleW: CGFloat = self.view.frame.width//200.0
        let appTitleH: CGFloat = 14.0
        let appTitleX: CGFloat = 0 //self.view.frame.width/2 - appTitleW/2
        let appTitleY: CGFloat = isIPhoneX ? 40.0 : 20.0
        appTitleLabel.frame = CGRect(x:appTitleX, y: appTitleY, width: appTitleW, height: appTitleH)
        appTitleLabel.text = "  Open GPX Tracker"
        appTitleLabel.textAlignment = .left
        appTitleLabel.font = UIFont.boldSystemFont(ofSize: 10)
        //appTitleLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        appTitleLabel.textColor = UIColor.yellow
        appTitleLabel.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        self.view.addSubview(appTitleLabel)
        
        // CoordLabel
        coordsLabel.frame = CGRect(x: self.map.frame.width - 305, y: appTitleY, width: 300, height: 12)
        coordsLabel.textAlignment = .right
        coordsLabel.font = font12
        coordsLabel.textColor = UIColor.white
        coordsLabel.text = kNotGettingLocationText
        self.view.addSubview(coordsLabel)
        
        // Tracked info
        let iPhoneXdiff: CGFloat  = isIPhoneX ? 40 : 0
        //timeLabel
        timeLabel.frame = CGRect(x: self.map.frame.width - 160, y: 20 + iPhoneXdiff, width: 150, height: 40)
        timeLabel.textAlignment = .right
        timeLabel.font = font36
        timeLabel.text = "00:00"
        //timeLabel.shadowColor = UIColor.whiteColor()
        //timeLabel.shadowOffset = CGSize(width: 1, height: 1)
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(timeLabel)
        
        //speed Label
        speedLabel.frame = CGRect(x: self.map.frame.width - 160,  y: 20 + 36 + iPhoneXdiff, width: 150, height: 20)
        speedLabel.textAlignment = .right
        speedLabel.font = font18
        speedLabel.text = "0.00 km/h"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(speedLabel)
        
        //tracked distance
        totalTrackedDistanceLabel.frame = CGRect(x: self.map.frame.width - 160, y: 60 + 20 + iPhoneXdiff, width: 150, height: 40)
        totalTrackedDistanceLabel.textAlignment = .right
        totalTrackedDistanceLabel.font = font36
        totalTrackedDistanceLabel.text = "0m"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(totalTrackedDistanceLabel)
        
        currentSegmentDistanceLabel.frame = CGRect(x: self.map.frame.width - 160, y: 80 + 36 + iPhoneXdiff, width: 150, height: 20)
        currentSegmentDistanceLabel.textAlignment = .right
        currentSegmentDistanceLabel.font = font18
        currentSegmentDistanceLabel.text = "0m"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(currentSegmentDistanceLabel)
        
        //about button
        aboutButton.frame = CGRect(x: 5 + 8, y: 14 + 5 + 48 + 5 + iPhoneXdiff, width: 32, height: 32)
        aboutButton.setImage(UIImage(named: "info"), for: UIControlState())
        aboutButton.setImage(UIImage(named: "info_high"), for: .highlighted)
        aboutButton.addTarget(self, action: #selector(ViewController.openAboutViewController), for: .touchUpInside)
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        map.addSubview(aboutButton)
        
        // Preferences button
        preferencesButton.frame = CGRect(x: 5 + 10 + 48, y: 14 + 5 + 8  + iPhoneXdiff, width: 32, height: 32)
        preferencesButton.setImage(UIImage(named: "prefs"), for: UIControlState())
        preferencesButton.setImage(UIImage(named: "prefs_high"), for: .highlighted)
        preferencesButton.addTarget(self, action: #selector(ViewController.openPreferencesTableViewController), for: .touchUpInside)
        //aboutButton.backgroundColor = kWhiteBackgroundColor
        //aboutButton.layer.cornerRadius = 24
        map.addSubview(preferencesButton)
        
        // Folder button
        let folderW: CGFloat = kButtonSmallSize
        let folderH: CGFloat = kButtonSmallSize
        let folderX: CGFloat = folderW/2 + 5
        let folderY: CGFloat = folderH/2 + 5 + 14  + iPhoneXdiff
        folderButton.frame = CGRect(x: 0, y: 0, width: folderW, height: folderH)
        folderButton.center = CGPoint(x: folderX, y: folderY)
        folderButton.setImage(UIImage(named: "folder"), for: UIControlState())
        folderButton.setImage(UIImage(named: "folderHigh"), for: .highlighted)
        folderButton.addTarget(self, action: #selector(ViewController.openFolderViewController), for: .touchUpInside)
        folderButton.backgroundColor = kWhiteBackgroundColor
        folderButton.layer.cornerRadius = 24
        map.addSubview(folderButton)
        
        //
        // Button Bar
        //
        // [ Small ] [ Small ] [ Large     ] [Small] [ Small]
        //                     [ (tracker) ]
        //
        //                     [ track     ]
        // [ follow] [ +Pin  ] [ Pause     ] [ Save ] [ Reset]
        //                     [ Resume    ]
        //
        //                       trackerX
        //                         |
        //                         |
        // [-----------------------|--------------------------]
        //                  map.frame/2 (center)
        
        let yCenterForButtons: CGFloat = map.frame.height - kButtonLargeSize/2 - 5 //center Y of start
        
        
        // Add signal accuracy images and labels
        signalImageView.image = signalImage0
        signalImageView.frame = CGRect(x: self.view.frame.width/2 - 25.0, y:  14 + 5, width: 50, height: 30)
        map.addSubview(signalImageView)
        signalAccuracyLabel.frame = CGRect(x: self.view.frame.width/2 - 25.0, y:  14 + 5 + 30 , width: 50, height: 10)
        signalAccuracyLabel.font = font8
        signalAccuracyLabel.text = kUnknownAccuracyText
        signalAccuracyLabel.textAlignment = .center
        map.addSubview(signalAccuracyLabel)
        
        
        // Start/Pause button
        let trackerW: CGFloat = kButtonLargeSize
        let trackerH: CGFloat = kButtonLargeSize
        let trackerX: CGFloat = self.map.frame.width/2 - 0.0 // Center of start
        let trackerY: CGFloat = yCenterForButtons
        trackerButton.frame = CGRect(x: 0, y:0, width: trackerW, height: trackerH)
        trackerButton.center = CGPoint(x: trackerX, y: trackerY)
        trackerButton.layer.cornerRadius = trackerW/2
        trackerButton.setTitle("Start Tracking", for: UIControlState())
        trackerButton.backgroundColor = kGreenButtonBackgroundColor
        trackerButton.addTarget(self, action: #selector(ViewController.trackerButtonTapped), for: .touchUpInside)
        trackerButton.isHidden = false
        trackerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        trackerButton.titleLabel?.numberOfLines = 2
        trackerButton.titleLabel?.textAlignment = .center
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
        newPinButton.setImage(UIImage(named: "addPin"), for: UIControlState())
        newPinButton.setImage(UIImage(named: "addPinHigh"), for: .highlighted)
        newPinButton.addTarget(self, action: #selector(ViewController.addPinAtMyLocation), for: .touchUpInside)
        //let newPinLongPress = UILongPressGestureRecognizer(target: self, action: Selector("newPinLongPress:"))
        //newPinButton.addGestureRecognizer(newPinLongPress)
        map.addSubview(newPinButton)
        
        // Follow user button
        let followW: CGFloat = kButtonSmallSize
        let followH: CGFloat = kButtonSmallSize
        let followX: CGFloat = newPinX - newPinW/2 - kButtonSeparation - followW/2
        let followY: CGFloat = yCenterForButtons
        followUserButton.frame = CGRect(x: 0, y: 0, width: followW, height: followH)
        followUserButton.center = CGPoint(x: followX, y: followY)
        followUserButton.layer.cornerRadius = followW/2
        followUserButton.backgroundColor = kWhiteBackgroundColor
        //follow_user_high represents the user is being followed. Default status when app starts
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: UIControlState())
        followUserButton.setImage(UIImage(named: "follow_user_high"), for: .highlighted)
        followUserButton.addTarget(self, action: #selector(ViewController.followButtonTroggler), for: .touchUpInside)
        map.addSubview(followUserButton)
        
        // Save button
        let saveW: CGFloat = kButtonSmallSize
        let saveH: CGFloat = kButtonSmallSize
        let saveX: CGFloat = trackerX + trackerW/2 + kButtonSeparation + saveW/2
        let saveY: CGFloat = yCenterForButtons
        saveButton.frame = CGRect(x: 0, y: 0, width: saveW, height: saveH)
        saveButton.center = CGPoint(x: saveX, y: saveY)
        saveButton.layer.cornerRadius = saveW/2
        saveButton.setTitle("Save", for: UIControlState())
        saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
        saveButton.addTarget(self, action: #selector(ViewController.saveButtonTapped), for: .touchUpInside)
        saveButton.isHidden = false
        saveButton.titleLabel?.textAlignment = .center
        map.addSubview(saveButton)
        
        // Reset button
        let resetW: CGFloat = kButtonSmallSize
        let resetH: CGFloat = kButtonSmallSize
        let resetX: CGFloat = saveX + saveW/2 + kButtonSeparation + resetW/2
        let resetY: CGFloat = yCenterForButtons
        resetButton.frame = CGRect(x: 0, y: 0, width: resetW, height: resetH)
        resetButton.center = CGPoint(x: resetX, y: resetY)
        resetButton.layer.cornerRadius = resetW/2
        resetButton.setTitle("Reset", for: UIControlState())
        resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
        resetButton.addTarget(self, action: #selector(ViewController.resetButtonTapped), for: .touchUpInside)
        resetButton.isHidden = false
        resetButton.titleLabel?.textAlignment = .center
        map.addSubview(resetButton)
    }
    
    ///
    /// Asks the system to notify the app on some events
    ///
    /// Current implementation requests the system to notify the app whenever it enters background
    ///
    func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.didEnterBackground),
            name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    ///
    /// Removes the notification observers
    ///
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notifications
    
    ///
    /// Actions to do in case the app entered in background
    ///
    /// In current implementation if the app is not tracking it requests the OS to stop
    /// sharing the location to save battery.
    ///
    func didEnterBackground() {
        print("viewController:: didEnterBackground")
        if gpxTrackingStatus != .tracking {
            locationManager.stopUpdatingLocation()
        }
    }
    
    ///
    /// Displays the view controller with the list of GPX Files.
    ///
    func openFolderViewController() {
        print("openFolderViewController")
        let vc = GPXFilesTableViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
    ///
    /// Displays the view controller with the About information.
    ///
    func openAboutViewController() {
        let vc = AboutViewController(nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
    func openPreferencesTableViewController() {
        print("openPreferencesTableViewController")
        let vc = PreferencesTableViewController(style: .grouped)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true) { () -> Void in }
    }
    
    ///
    /// After invoking this fuction, the map will not be centered on current user position.
    ///
    func stopFollowingUser(_ gesture: UIPanGestureRecognizer) {
        if self.followUser {
            self.followUser = false
        }
    }
    
    ///
    /// UIGestureRecognizerDelegate required for stopFollowingUser
    ///
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
   
    ///
    /// If user long presses the map for a while a Pin (Waypoint/Annotation) will be dropped at that point.
    ///
    func addPinAtTappedLocation(_ gesture: UILongPressGestureRecognizer) {
        if  gesture.state == UIGestureRecognizerState.began {
            print("Adding Pin map Long Press Gesture")
            let point: CGPoint = gesture.location(in: self.map)
            map.addWaypointAtViewPoint(point)
            //Allows save and reset
            self.hasWaypoints = true
        }
    }
    
    // Zoom gesture controls that follow user to
    func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
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
    
    ///
    /// It adds a Pin (Waypoint/Annotation) to current user location.
    ///
    func addPinAtMyLocation() {
        print("Adding Pin at my location")
        let waypoint = GPXWaypoint(coordinate: map.userLocation.coordinate)
        map.addWaypoint(waypoint)
        self.hasWaypoints = true
    }
    
    ///
    /// Triggered when follow Button is taped.
    //
    /// Trogles between following or not following the user, that is, automatically centering the map
    //  in current user´s position.
    ///
    func followButtonTroggler() {
        self.followUser = !self.followUser
    }
    
    ///
    /// Triggered when reset button was tapped.
    ///
    /// It sets map to status .notStarted which clears the map.
    ///
    func resetButtonTapped() {
        self.gpxTrackingStatus = .notStarted
    }
    

    ///
    /// Main Start/Pause Button was tapped.
    ///
    /// It sets the status to tracking or paused.
    ///
    func trackerButtonTapped() {
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
    /// Triggered when user taps on save Button
    ///
    /// It prompts the user to set a name of the file.
    ///
    func saveButtonTapped() {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .notStarted) && !self.hasWaypoints {
            return
        }
        
        let alert = UIAlertView(title: "Save as", message: "Enter GPX session name", delegate: self, cancelButtonTitle: "Continue tracking")
        
        alert.addButton(withTitle: "Save")
        alert.alertViewStyle = .plainTextInput
        alert.tag = kSaveSessionAlertViewTag
        alert.show()
        alert.textField(at: 0)?.text = lastGpxFilename
        //alert.textFieldAtIndex(0)?.selectAll(self)
    }
    
    ///
    /// There was a memory warning. Right now, it does nothing but to log a line.
    ///
    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning");
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: UIAlertViewDelegate

///
/// AlertView delegate to manage the selected option when user clicks the Save button in the main View Controller.
///
///
/// The alertview displays two text field with the name of the file to be saved and two buttons (0) Cancel and (1) Save.

extension ViewController: UIAlertViewDelegate {

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        switch alertView.tag {
        case kSaveSessionAlertViewTag:
            
            print("alertViewDelegate for Save Session")
            
            switch buttonIndex {
            case 0: //cancel
                print("Save canceled")
                
            case 1: //Save
                let filename = (alertView.textField(at: 0)?.text!.utf16.count == 0) ? " " : alertView.textField(at: 0)?.text
                print("Save File \(String(describing: filename))")
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
}

// MARK: StopWatchDelegate

///
/// Updates the `timeLabel` with the `stopWatch` elapsedTime.
/// In the main ViewController there is a label that holds the elapsed time, that is, the time that
/// user has been tracking his position.
///
///
extension ViewController: StopWatchDelegate {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        timeLabel.text = elapsedTimeString
    }
}

// MARK: PreferencesTableViewControllerDelegate

extension ViewController: PreferencesTableViewControllerDelegate {
    ///
    /// Updates the `tileServer` the map is using.
    ///
    /// If user enters preferences and he changes his preferences regarding the `tileServer`,
    /// the map of the main `ViewController` needs to be aware of it.
    ///
    /// `PreferencesTableViewController` informs the main `ViewController` through this delegate.
    ///
    func didUpdateTileServer(_ newGpxTileServer: Int) {
        print("** Preferences:: didUpdateTileServer: \(newGpxTileServer)")
        self.map.tileServer = GPXTileServer(rawValue: newGpxTileServer)!
    }
    
    ///
    /// If user changed the setting of using cache, through this delegate, the main `ViewController`
    /// informs the map to behave accordingly.
    ///
    func didUpdateUseCache(_ newUseCache: Bool) {
        print("** Preferences:: didUpdateUseCache: \(newUseCache)")
        self.map.useCache = newUseCache
    }
}

// MARK: location manager Delegate


extension ViewController: GPXFilesTableViewControllerDelegate {
    ///
    /// Loads the selected GPX File into the map.
    ///
    /// Resets whatever estatus was before.
    ///
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot) {
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
        self.gpxTrackingStatus = .paused
        
        self.totalTrackedDistanceLabel.distance = self.map.totalTrackedDistance
        
    }
}

// MARK: CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError\(error)")
        coordsLabel.text = kNotGettingLocationText
        signalAccuracyLabel.text = kUnknownAccuracyText
        signalImageView.image = signalImage0
    }
    
    ///
    /// Updates location accuracy and map information when user is in a new position
    ///
    ///
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //updates signal image accuracy
        let newLocation = locations.first!
        print("isUserLocationVisible: \(map.isUserLocationVisible) showUserLocation: \(map.showsUserLocation)")
        print("didUpdateLocation: received \(newLocation.coordinate) hAcc: \(newLocation.horizontalAccuracy) vAcc: \(newLocation.verticalAccuracy) floor: \(newLocation.floor)")
        let hAcc = newLocation.horizontalAccuracy
        signalAccuracyLabel.text = "±\(hAcc)m"
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
        let altFormat = String(format: "%.2f", newLocation.altitude)
        coordsLabel.text = "(\(latFormat),\(lonFormat)) · altitude: \(altFormat)m"
        
        
        //Update speed (provided in m/s, but displayed in km/h)
        var speedFormat: String
        if newLocation.speed < 0 {
            speedFormat = kUnknownSpeedText
        } else {
            speedFormat = String(format: "%.2f", (newLocation.speed * 3.6))
        }
        speedLabel.text = "\(speedFormat) km/h"
        
        //Update Map center and track overlay if user is being followed
        if followUser {
            map.setCenter(newLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .tracking {
            print("didUpdateLocation: adding point to track \(newLocation.coordinate)")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel.distance = map.totalTrackedDistance
            currentSegmentDistanceLabel.distance = map.currentSegmentDistance
        }
    }
}
