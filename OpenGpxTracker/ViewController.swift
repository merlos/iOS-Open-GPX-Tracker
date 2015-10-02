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


class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, GPXFilesTableViewControllerDelegate, StopWatchDelegate {
    
    var followUser: Bool = true {
        didSet {
            if (followUser) {
                print("followUser=true");
                followUserButton.setImage(UIImage(named: "follow_user_high"), forState: .Normal)
                map.setCenterCoordinate(map.userLocation.coordinate, animated: true)
                
            } else {
                print("followUser=false");
               followUserButton.setImage(UIImage(named: "follow_user"), forState: .Normal)
            }
            
        }
    }
    var followUserBeforePinchGesture = true
    
    
    //MapView
    let locationManager : CLLocationManager
    let map: GPXMapView
    
    
    
    //Status Vars
    var stopWatch = StopWatch()
    var lastGpxFilename: String = ""
    
    var hasWaypoints: Bool = false { // Was any waypoint added to the map?
        didSet {
            if (hasWaypoints) {
                self.saveButton.backgroundColor = kBlueButtonBackgroundColor
                self.resetButton.backgroundColor = kRedButtonBackgroundColor
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
                self.trackerButton.setTitle("Start Tracking", forState: .Normal)
                self.trackerButton.backgroundColor = kGreenButtonBackgroundColor
                //save & reset button to transparent.
                self.saveButton.backgroundColor = kDisabledBlueButtonBackgroundColor
                self.resetButton.backgroundColor = kDisabledRedButtonBackgroundColor
                //reset clock
                self.stopWatch.reset()
                self.timeLabel.text = stopWatch.elapsedTimeString
                
                self.map.clearMap() //clear map
                self.lastGpxFilename = "" //clear last filename, so when saving it appears an empty field
                
                self.totalTrackedDistanceLabel.distance = self.map.totalTrackedDistance
                self.currentSegmentDistanceLabel.distance = self.map.currentSegmentDistance
                
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
                self.trackerButton.setTitle("Pause", forState: .Normal)
                self.trackerButton.backgroundColor = kPurpleButtonBackgroundColor
                //activate save & reset buttons
                self.saveButton.backgroundColor = kBlueButtonBackgroundColor
                self.resetButton.backgroundColor = kRedButtonBackgroundColor
                // start clock
                self.stopWatch.start()
                
            case .Paused:
                print("switched to paused mode")
                // set trackerButton to allow Resume
                self.trackerButton.setTitle("Resume", forState: .Normal)
                self.trackerButton.backgroundColor = kGreenButtonBackgroundColor
                // activate save & reset (just in case switched from .NotStarted)
                self.saveButton.backgroundColor = kBlueButtonBackgroundColor
                self.resetButton.backgroundColor = kRedButtonBackgroundColor
                //pause clock
                self.stopWatch.stop()
                // start new track segment
                self.map.startNewTrackSegment()
            }
        }
    }

    //Editing Waypoint Temporal Reference
    var waypointBeingEdited : GPXWaypoint = GPXWaypoint()
    var lastLocation: CLLocation? //Last point of current segment.
    
    
    //UI
    //labels
    let appTitleLabel: UILabel
    let signalImageView: UIImageView
    let coordsLabel: UILabel
    let timeLabel : UILabel
    let speedLabel : UILabel
    let totalTrackedDistanceLabel : UIDistanceLabel
    let currentSegmentDistanceLabel : UIDistanceLabel
 
    
    //buttons
    let followUserButton: UIButton
    let newPinButton: UIButton
    let folderButton: UIButton
    let aboutButton: UIButton
    let resetButton: UIButton
    let trackerButton: UIButton
    let saveButton: UIButton
    
    
    let badSignalImage = UIImage(named: "1")
    let midSignalImage = UIImage(named: "2")
    let goodSignalImage = UIImage(named: "3")
   
 
    // Initializer. Just initializes the class vars/const
    required init(coder aDecoder: NSCoder) {
    
        self.locationManager = CLLocationManager()
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
        
        self.trackerButton = UIButton(coder: aDecoder)!
        self.saveButton = UIButton(coder: aDecoder)!
        super.init(coder: aDecoder)!
        followUser = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopWatch.delegate = self
        
        //Location stuff
        locationManager.requestAlwaysAuthorization()
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 2
        locationManager.startUpdatingLocation()
        
        
        // Map configuration Stuff
        map.delegate = self
        map.showsUserLocation = true
        let mapH: CGFloat = self.view.bounds.size.height - 20.0
        map.frame = CGRect(x: 0.0, y: 20.0, width: self.view.bounds.size.width, height: mapH)
        map.zoomEnabled = true
        map.rotateEnabled = true
        map.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: "addPinAtTappedLocation:")
        )
        let panGesture = UIPanGestureRecognizer(target: self, action: "stopFollowingUser:")
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
       
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "pinchGesture")
        map.addGestureRecognizer(pinchGesture)
        
        //Set Tile Server
        map.tileServer = GPXTileServer.Apple
        
        // set default zoon
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        map.setRegion(region, animated: true)
        
        self.view.addSubview(map)
        
        //add signal accuracy images.
        signalImageView.image = badSignalImage
        signalImageView.frame = CGRect(x: self.view.frame.width/2 - 25.0, y: 28 + 14, width: 50, height: 30)
        map.addSubview(signalImageView)
        
        //about button
        aboutButton.frame = CGRect(x: self.view.frame.width - 47, y: 14 + 5, width: 32, height: 32)
        aboutButton.setImage(UIImage(named: "info"), forState: UIControlState.Normal)
        aboutButton.setImage(UIImage(named: "info_high"), forState: .Highlighted)
        aboutButton.addTarget(self, action: "openAboutViewController", forControlEvents: .TouchUpInside)
        map.addSubview(aboutButton)
    
        
        //add the app title Label (Branding, branding, branding! )
        let appTitleW: CGFloat = self.view.frame.width//200.0
        let appTitleH: CGFloat = 14.0
        let appTitleX: CGFloat = 0 //self.view.frame.width/2 - appTitleW/2
        let appTitleY: CGFloat = 20
        appTitleLabel.frame = CGRect(x:appTitleX, y: appTitleY, width: appTitleW, height: appTitleH)
        appTitleLabel.text = "Open GPX Tracker"
        appTitleLabel.textAlignment = .Center
        appTitleLabel.font = UIFont.boldSystemFontOfSize(10)
        //appTitleLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        appTitleLabel.textColor = UIColor.yellowColor()
        appTitleLabel.backgroundColor = UIColor(red: 58.0/255.0, green: 57.0/255.0, blue: 54.0/255.0, alpha: 0.80)
        self.view.addSubview(appTitleLabel)
        
        
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
        trackerButton.addTarget(self, action: "trackerButtonTapped", forControlEvents: .TouchUpInside)
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
        newPinButton.layer.cornerRadius = newPinW/2;
        newPinButton.backgroundColor = kWhiteBackgroundColor
        newPinButton.setImage(UIImage(named: "addPin"), forState: UIControlState.Normal)
        newPinButton.setImage(UIImage(named: "addPinHigh"), forState: .Highlighted)
        newPinButton.addTarget(self, action: "addPinAtMyLocation", forControlEvents: .TouchUpInside)
        let newPinLongPress = UILongPressGestureRecognizer(target: self, action: "newPinLongPress:")
        newPinButton.addGestureRecognizer(newPinLongPress)
        map.addSubview(newPinButton)
        
        // Follow user button
        let followW: CGFloat = kButtonSmallSize
        let followH: CGFloat = kButtonSmallSize
        let followX: CGFloat = newPinX - newPinW/2 - kButtonSeparation - followW/2
        let followY: CGFloat = yCenterForButtons
        followUserButton.frame = CGRect(x: 0, y: 0, width: followW, height: followH)
        followUserButton.center = CGPointMake(followX, followY)
        followUserButton.layer.cornerRadius = followW/2;
        followUserButton.backgroundColor = kWhiteBackgroundColor
        //follow_user_high represents the user is being followed. Default status when app starts
        followUserButton.setImage(UIImage(named: "follow_user_high"), forState: UIControlState.Normal)
        followUserButton.setImage(UIImage(named: "follow_user_high"), forState: .Highlighted)
        followUserButton.addTarget(self, action: "followButtonTroggler", forControlEvents: .TouchUpInside)
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
        saveButton.addTarget(self, action: "saveButtonTapped", forControlEvents: .TouchUpInside)
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
        resetButton.addTarget(self, action: "resetButtonTapped", forControlEvents: .TouchUpInside)
        resetButton.hidden = false
        resetButton.titleLabel?.textAlignment = .Center
        map.addSubview(resetButton)
        
        // Folder button
        let folderW: CGFloat = kButtonSmallSize
        let folderH: CGFloat = kButtonSmallSize
        let folderX: CGFloat = folderW/2 + 5
        let folderY: CGFloat = folderH/2 + 5 + 14
        folderButton.frame = CGRect(x: 0, y: 0, width: folderW, height: folderH)
        folderButton.center = CGPoint(x: folderX, y: folderY)
        folderButton.setImage(UIImage(named: "folder"), forState: UIControlState.Normal)
        folderButton.setImage(UIImage(named: "folderHigh"), forState: .Highlighted)
        folderButton.addTarget(self, action: "openFolderViewController", forControlEvents: .TouchUpInside)
        folderButton.backgroundColor = kWhiteBackgroundColor
        folderButton.layer.cornerRadius = 24;
        map.addSubview(folderButton)
        
        // CoordLabel
        coordsLabel.frame = CGRect(x: self.map.frame.width/2 - 150, y: 14 + 2, width: 300, height: 20)
        coordsLabel.textAlignment = .Center
        coordsLabel.font = UIFont.systemFontOfSize(14)
        coordsLabel.text = "Not getting location"
        map.addSubview(coordsLabel)
        
        //timeLabel
        timeLabel.frame = CGRect(x: self.map.frame.width/2 - 150, y: map.frame.height -  trackerH - 25, width: 300, height: 20)
        timeLabel.textAlignment = .Center
        timeLabel.font = UIFont.boldSystemFontOfSize(14)
        timeLabel.text = "00:00:00"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(timeLabel)
        
        //speed Label
        speedLabel.frame = CGRect(x: self.map.frame.width/2 - 150, y: map.frame.height -  trackerH - 45, width: 300, height: 20)
        speedLabel.textAlignment = .Center
        speedLabel.font = UIFont.boldSystemFontOfSize(14)
        speedLabel.text = "0.00 km/h"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(speedLabel)
        
        //tracked distance
        totalTrackedDistanceLabel.frame = CGRect(x: self.map.frame.width/2 - 150, y: map.frame.height -  trackerH - 65, width: 300, height: 20)
        totalTrackedDistanceLabel.textAlignment = .Center
        totalTrackedDistanceLabel.font = UIFont.boldSystemFontOfSize(14)
        totalTrackedDistanceLabel.text = "0 m"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(totalTrackedDistanceLabel)
        
        currentSegmentDistanceLabel.frame = CGRect(x: self.map.frame.width/2 - 150, y: map.frame.height -  trackerH - 85, width: 300, height: 20)
        currentSegmentDistanceLabel.textAlignment = .Center
        currentSegmentDistanceLabel.font = UIFont.boldSystemFontOfSize(14)
        currentSegmentDistanceLabel.text = "0 m"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(currentSegmentDistanceLabel)
    }

    
    func openFolderViewController() {
        print("OpenFolderViewController")
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
    
    
    func stopFollowingUser(gesture: UIPanGestureRecognizer) {
        if self.followUser {
            self.followUser = false
        }
    }
    
    
    // UIGestureRecognizerDelegate required for stopFollowingUser
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        print("pinchGesture");
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
    
    
    func followButtonTroggler(){
        self.followUser = !self.followUser
    }
    
    
    func resetButtonTapped() {
        //clear tracks, pins and overlays if not already in that status
        if (self.gpxTrackingStatus != .NotStarted) {
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
        default:
            print("ERROR: startGpxTracking")
        }
    }
    
    
    func saveButtonTapped() {
        print("save Button tapped")
        // ignore the save button if there is nothing to save.
        if (gpxTrackingStatus == .NotStarted) && !self.hasWaypoints {
            return;
        }
        
        let alert = UIAlertView(title: "Save as", message: "Enter GPX session name", delegate: self, cancelButtonTitle: "Continue tracking")
        
        alert.addButtonWithTitle("Save")
        alert.alertViewStyle = .PlainTextInput;
        alert.tag = kSaveSessionAlertViewTag
        alert.show();
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
                //println(gpx.gpx())
                self.lastGpxFilename = filename!
                
            default:
            print("[ERROR] it seems there are more than two buttons on the alertview.")
        
            } //buttonIndex
        case kEditWaypointAlertViewTag:
            print("Edit waypoint alert view")
            self.waypointBeingEdited.title = alertView.textFieldAtIndex(0)?.text
            
        default:
            print("[ERROR] it seems that the AlertView is not handled properly." )
            
        }
    }
    
    
    //#pragma mark - location manager Delegate
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
         print("didFailWithError\(error)");
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        //println("didUpdateToLocation \(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude), Hacc: \(newLocation.horizontalAccuracy), Vacc: \(newLocation.verticalAccuracy)")
      
        //updates signal image accuracy
        if (newLocation.horizontalAccuracy < kMediumSignalAccuracy) {
            self.signalImageView.image = midSignalImage;
        } else {
            self.signalImageView.image = badSignalImage;
        }
        if (newLocation.horizontalAccuracy < kGoodSignalAccuracy) {
            self.signalImageView.image = goodSignalImage;
        }
        
        //Update coordsLabel
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        coordsLabel.text = "(\(latFormat),\(lonFormat))"
        
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
            map.setCenterCoordinate(map.userLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .Tracking {
            print("didUpdateLocation: adding point to track \(newLocation.coordinate)")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
            totalTrackedDistanceLabel.distance = map.totalTrackedDistance;
            currentSegmentDistanceLabel.distance = map.currentSegmentDistance;
        }
        
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView! {
        if (annotation.isKindOfClass(MKUserLocation)) {
            return nil
        }
        let annotationView : MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PinView")
        annotationView.canShowCallout = true
        annotationView.draggable = true
        //let detailButton : UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
        
        let deleteButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        deleteButton.setImage(UIImage(named: "delete"), forState: .Normal)
        deleteButton.setImage(UIImage(named: "deleteHigh"), forState: .Highlighted)
        deleteButton.tag = kDeleteWaypointAccesoryButtonTag
        annotationView.rightCalloutAccessoryView = deleteButton
        
        let editButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        editButton.setImage(UIImage(named: "edit"), forState: .Normal)
        editButton.setImage(UIImage(named: "editHigh"), forState: .Highlighted)
        editButton.tag = kEditWaypointAccesoryButtonTag
        annotationView.leftCalloutAccessoryView = editButton
        
        return annotationView;
    }
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer! {
        if (overlay.isKindOfClass(MKTileOverlay)) {
            return MKTileOverlayRenderer(overlay: overlay)
        }
        
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5);
            pr.lineWidth = 3;
            return pr;
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccesoryControlTapped ")
        let waypoint = view.annotation as! GPXWaypoint
        let button = control as! UIButton
        switch button.tag {
        case kDeleteWaypointAccesoryButtonTag:
            print("[calloutAccesoryControlTapped: DELETE button] deleting waypoint with name \(waypoint.name)");
            map.removeWaypoint(waypoint)
        case kEditWaypointAccesoryButtonTag:
            print("[calloutAccesoryControlTapped: EDIT] editing waypoint with name \(waypoint.name)")
            let alert = UIAlertView(title: "Edit Waypoint", message: "Hint: To change the waypoint location drag and drop the pin" , delegate: self, cancelButtonTitle: "Cancel")
            alert.addButtonWithTitle("Save")
            alert.tag = kEditWaypointAlertViewTag
            alert.alertViewStyle = .PlainTextInput;
            alert.textFieldAtIndex(0)?.text = waypoint.title
            alert.show();
            self.waypointBeingEdited = waypoint
            alert.textFieldAtIndex(0)?.selectAll(self) //display text selected <-- TODO Not working WTF!

        default:
            print("[calloutAccesoryControlTapped ERROR] unknown control")
        }
    }
    

    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if (newState == MKAnnotationViewDragState.Ending){
            let point = view.annotation as! GPXWaypoint
            print("Annotation name: \(point.title) lat:\(point.latitude) lon \(point.longitude)")
        }
    }
    
    
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        var i = 0
        for object in views {
            i++
            let aV = object as MKAnnotationView
            if aV.annotation!.isKindOfClass(MKUserLocation) { continue }
            
            let point : MKMapPoint = MKMapPointForCoordinate(aV.annotation!.coordinate)
            if !MKMapRectContainsPoint(self.map.visibleMapRect, point) { continue }
         
            let endFrame: CGRect = aV.frame
            aV.frame = CGRect(x: aV.frame.origin.x, y: aV.frame.origin.y - self.view.frame.size.height, width: aV.frame.size.width, height:aV.frame.size.height)
            let interval : NSTimeInterval = 0.04 * 1.1
            UIView.animateWithDuration(0.5, delay: interval, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                aV.frame = endFrame
                }, completion: { (finished) -> Void in
                    if finished {
                        UIView.animateWithDuration(0.05, animations: { () -> Void in
                            //aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                            aV.transform = CGAffineTransform(a: 1.0, b: 0, c: 0, d: 0.8, tx: 0, ty: aV.frame.size.height*0.1)
                            
                            }, completion: { (finished: Bool) -> Void in
                            UIView.animateWithDuration(0.1, animations: { () -> Void in
                                aV.transform = CGAffineTransformIdentity
                                })
                        })
                    }
            })
        }
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

