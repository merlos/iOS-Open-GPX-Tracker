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
let kPauseButtonBackgroundColor: UIColor =  UIColor(red: 146.0/255.0, green: 166.0/255.0, blue: 218.0/255.0, alpha: 0.90)
let kResumeButtonBackgroundColor: UIColor =  UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)
let kStartButtonBackgroundColor: UIColor = UIColor(red: 142.0/255.0, green: 224.0/255.0, blue: 102.0/255.0, alpha: 0.90)
let kStopButtonBackgroundColor: UIColor =  UIColor(red: 244.0/255.0, green: 94.0/255.0, blue: 94.0/255.0, alpha: 0.90)

let kFolloUserBackgroundColor: UIColor = UIColor(red: 254.0/255.0, green: 254.0/255.0, blue: 254.0/255.0, alpha: 0.90)

//Accesory View buttons tags
let kDeleteWaypointAccesoryButtonTag = 666
let kEditWaypointAccesoryButtonTag = 333

//AlertViews tags
let kEditWaypointAlertViewTag = 33
let kSaveSessionAlertViewTag = 88


class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, GPXFilesTableViewControllerDelegate, StopWatchDelegate {
    
    //MapView
    let locationManager : CLLocationManager
    let map: GPXMapView
    
    
    
    //Status Vars
    var followUser = true // MapView centered in user location
    var stopWatch = StopWatch()
    var lastLoadedSessionFilename: String = ""
    
    enum GpxTrackingStatus {
        case NotStarted
        case Tracking
        case Paused
        case Finished
    }
    var gpxTrackingStatus = GpxTrackingStatus.NotStarted
    var pinSeq = 1
    var trackSeq = 1

    //Editing Waypoint Temporal Reference
    var waypointBeingEdited : GPXWaypoint = GPXWaypoint()

    //UI
    //labels
    let appTitleLabel: UILabel
    let signalImageView: UIImageView
    let coordsLabel: UILabel
    let timeLabel : UILabel
    let trackedDistanceLabel : UILabel
    let segmentDistanceLabel : UILabel
    
    //buttons
    let followUserButton: UIButton
    let newPinButton: UIButton
    let folderButton: UIButton
    let aboutButton: UIButton
    let startButton: UIButton
    let stopButton: UIButton
    var pauseButton: UIButton // Pause & Resume
    
    let badSignalImage = UIImage(named: "1")
    let midSignalImage = UIImage(named: "2")
    let goodSignalImage = UIImage(named: "3")
   
 
    // Initializer. Just initializes the class vars/const
    required init(coder aDecoder: NSCoder) {
        
        self.locationManager = CLLocationManager()
        self.map = GPXMapView(coder: aDecoder)
        
        self.appTitleLabel = UILabel(coder: aDecoder)
        self.signalImageView = UIImageView(coder: aDecoder)
        self.coordsLabel = UILabel(coder: aDecoder)
        
        self.timeLabel = UILabel(coder: aDecoder)
        self.trackedDistanceLabel = UILabel(coder: aDecoder)
        self.segmentDistanceLabel = UILabel(coder: aDecoder)
        
        self.followUserButton = UIButton(coder: aDecoder)
        self.newPinButton = UIButton(coder: aDecoder)
        self.folderButton = UIButton(coder: aDecoder)
        self.aboutButton = UIButton(coder: aDecoder)
        
        self.startButton = UIButton(coder: aDecoder)
        self.stopButton = UIButton(coder: aDecoder)
        self.pauseButton = UIButton(coder: aDecoder)
        
        super.init(coder: aDecoder)
      
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopWatch.delegate = self
        
        //Location stuff
        if iOS8 {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 2
        locationManager.startUpdatingLocation()
        
        
        // Map configuration Stuff
        map.delegate = self
        map.showsUserLocation = true
        let mapH: CGFloat = self.view.bounds.size.height - 64.0
        map.frame = CGRect(x: 0, y: 64.0, width: self.view.bounds.size.width, height: mapH)
        map.zoomEnabled = true
        map.rotateEnabled = true
        map.addGestureRecognizer(
            UILongPressGestureRecognizer(target: self, action: "addPinAtTappedLocation:")
        )
        let panGesture = UIPanGestureRecognizer(target: self, action: "stopFollowingUser:")
        panGesture.delegate = self
        map.addGestureRecognizer(panGesture)
        
        // set default zoon
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50), span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        map.setRegion(region, animated: true)
        
        self.view.addSubview(map)
        
        //add signal accuracy images.
        signalImageView.image = badSignalImage
        signalImageView.frame = CGRect(x: self.view.frame.width/2 - 25.0, y: 28, width: 50, height: 30)
        map.addSubview(signalImageView)
        
        // add FolderButton
        folderButton.frame = CGRect(x: 5, y: 25, width: 32, height: 32)
        folderButton.setImage(UIImage(named: "folder"), forState: UIControlState.Normal)
        folderButton.setImage(UIImage(named: "folderHigh"), forState: .Highlighted)
        folderButton.addTarget(self, action: "openFolderViewController", forControlEvents: .TouchUpInside)
        self.view.addSubview(folderButton)
        
        //pin button
        newPinButton.frame = CGRect(x: self.view.frame.width/2 - 20 , y: 25, width: 32, height: 32)
        newPinButton.setImage(UIImage(named: "addPin"), forState: UIControlState.Normal)
        newPinButton.setImage(UIImage(named: "addPinHigh"), forState: .Highlighted)
        newPinButton.addTarget(self, action: "addPinAtMyLocation", forControlEvents: .TouchUpInside)
        let newPinLongPress = UILongPressGestureRecognizer(target: self, action: "newPinLongPress:")
        newPinButton.addGestureRecognizer(newPinLongPress)
        self.view.addSubview(newPinButton)

        
        
        //about button
        aboutButton.frame = CGRect(x: self.view.frame.width - 47, y: 25, width: 32, height: 32)
        aboutButton.setImage(UIImage(named: "info"), forState: UIControlState.Normal)
        aboutButton.setImage(UIImage(named: "info_high"), forState: .Highlighted)
        aboutButton.addTarget(self, action: "openAboutViewController", forControlEvents: .TouchUpInside)
        self.view.addSubview(aboutButton)
        

        
        /*
        //add the app title Label (Branding, branding, branding! )
        let appTitleW: CGFloat = 200.0
        let appTitleH: CGFloat = 34.0
        let appTitleX: CGFloat = self.view.frame.width/2 - appTitleW/2
        let appTitleY: CGFloat = 30.0
        appTitleLabel.frame = CGRect(x:appTitleX, y: appTitleY, width: appTitleW, height: appTitleH)
        appTitleLabel.text = "Open GPX Tracker"
        appTitleLabel.textAlignment = .Center
        appTitleLabel.font = UIFont.boldSystemFontOfSize(20)
        //appTitleLabel.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        appTitleLabel.textColor = UIColor(red: 7.0/255.0, green: 140.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        self.view.addSubview(appTitleLabel)
        */
        
        //FollowUserButton
        followUserButton.frame = CGRect(x: 5, y: map.frame.height-37, width: 32, height: 32)
        //follow_user_high represents the user is being followed. Default status when app starts
        followUserButton.setImage(UIImage(named: "follow_user_high"), forState: UIControlState.Normal)
        followUserButton.setImage(UIImage(named: "follow_user_high"), forState: .Highlighted)
        followUserButton.addTarget(self, action: "followButtonTroggler", forControlEvents: .TouchUpInside)
        followUserButton.backgroundColor = kFolloUserBackgroundColor
        followUserButton.layer.cornerRadius = 16;
        map.addSubview(followUserButton)
        
        
        //tracking buttons
        //start
        let startW: CGFloat = 80.0
        let startH: CGFloat = 80.0
        let startX: CGFloat = self.map.frame.width/2 - startW/2 + 10
        let startY: CGFloat = self.map.frame.height - startH - 5
        startButton.frame = CGRect(x: startX, y:startY, width: startW, height: startH)
        startButton.setTitle("Start Tracking", forState: .Normal)
        startButton.backgroundColor = kStartButtonBackgroundColor
        startButton.addTarget(self, action: "startGpxTracking", forControlEvents: .TouchUpInside)
        startButton.hidden = false
        startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        startButton.titleLabel?.numberOfLines = 2
        startButton.titleLabel?.textAlignment = .Center
        startButton.layer.cornerRadius = 40.0
        map.addSubview(startButton)
        
        //Stop
        let stopW: CGFloat = 70.0
        let stopH: CGFloat = 70.0
        let stopX: CGFloat = self.map.frame.width/2 + 15.0
        let stopY: CGFloat = self.map.frame.height - stopH - 5.0
        stopButton.frame = CGRect(x: stopX, y: stopY, width: stopW, height: stopH)
        stopButton.setTitle("Finish", forState: .Normal)
        stopButton.backgroundColor = kStopButtonBackgroundColor
        stopButton.addTarget(self, action: "stopGpxTracking", forControlEvents: .TouchUpInside)
        stopButton.hidden = true
        stopButton.titleLabel?.textAlignment = .Center
        stopButton.layer.cornerRadius = 35.0
        map.addSubview(stopButton)
        
        let pauseW: CGFloat = 70.0
        let pauseH: CGFloat = 70.0
        let pauseX: CGFloat = self.map.frame.width/2  - pauseW + 10.0
        let pauseY: CGFloat = self.map.frame.height - pauseH - 5.0
        pauseButton.frame = CGRect(x: pauseX, y: pauseY, width: pauseW, height: pauseH)
        pauseButton.backgroundColor = kPauseButtonBackgroundColor
        pauseButton.setTitle("Pause", forState: .Normal)
        pauseButton.addTarget(self, action: "pauseGpxTracking", forControlEvents: .TouchUpInside)
        pauseButton.hidden = true
        pauseButton.titleLabel?.textAlignment = .Center
        pauseButton.layer.cornerRadius = 35.0
        map.addSubview(pauseButton)
        
        //CoordLabel
        coordsLabel.frame = CGRect(x: self.map.frame.width/2 - 150, y: 2, width: 300, height: 20)
        coordsLabel.textAlignment = .Center
        coordsLabel.font = UIFont.systemFontOfSize(14)
        coordsLabel.text = "Not getting location"
        map.addSubview(coordsLabel)
        
        //timeLabel
        timeLabel.frame = CGRect(x: self.map.frame.width/2 - 150 + 12.5, y: map.frame.height -  startH - 25, width: 300, height: 20)
        timeLabel.textAlignment = .Center
        timeLabel.font = UIFont.boldSystemFontOfSize(14)
        timeLabel.text = "00:00:00"
        //timeLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        map.addSubview(timeLabel)
        

      
    
        
        
        
    }

    func openFolderViewController() {
        println("OpenFolderViewController")
        
        let vc = GPXFilesTableViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true) { () -> Void in
            
        }
    }
    
    func openAboutViewController() {
        let vc = AboutViewController(nibName: nil, bundle: nil)
        let navController = UINavigationController(rootViewController: vc)
        self.presentViewController(navController, animated: true) { () -> Void in }
    }
    
    func stopFollowingUser(gesture: UIPanGestureRecognizer) {
        println("Pan gesture detected: stop Following user")
        self.followUser = false
        followUserButton.setImage(UIImage(named: "follow_user"), forState: .Normal)
    }
    
    // UIGestureRecognizerDelegate required for stopFollowingUser
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
   func addPinAtTappedLocation(gesture: UILongPressGestureRecognizer) {
    
        if  gesture.state == UIGestureRecognizerState.Began {
            println("Adding Pin map Long Press Gesture")
            let point: CGPoint = gesture.locationInView(self.map)
            map.addWaypointAtViewPoint(point)
        }
    }
    
    //TODO
    func newPinLongPress(gesture: UILongPressGestureRecognizer) {
        if  gesture.state == UIGestureRecognizerState.Ended {
            println("Long Press");
        }
    }
    
    func addPinAtMyLocation() {
        println("Adding Pin at my location")
        let waypoint = GPXWaypoint(coordinate: map.userLocation.coordinate)
        map.addWaypoint(waypoint)
    }
    
    
    func followButtonTroggler(){
        if self.followUser {
            self.followUser = false
            followUserButton.setImage(UIImage(named: "follow_user"), forState: .Normal)
        } else {
            self.followUser = true
            followUserButton.setImage(UIImage(named: "follow_user_high"), forState: .Normal)
            map.setCenterCoordinate(map.userLocation.coordinate, animated: true)
           
        }
    }
    ////////////////////////////
    // TRACKING USER

    func pauseGpxTracking() {
        println("Paused/resumed GPX tracking")
        switch gpxTrackingStatus {
        case .Tracking, .Finished, .NotStarted:
            println("Paused GPX tracking")
            
            //update tracking status and add segment to track
            self.gpxTrackingStatus = GpxTrackingStatus.Paused
            self.map.startNewTrackSegment()
            
            self.pauseButton.setTitle("Resume", forState: .Normal)
            self.pauseButton.backgroundColor = UIColor.greenColor()
            self.pauseButton.backgroundColor = kResumeButtonBackgroundColor
            
            self.stopWatch.stop()
            
            
        case .Paused:
            println("Resumed GPX tracking")
            self.gpxTrackingStatus = GpxTrackingStatus.Tracking
            
            //update UI
            self.pauseButton.setTitle("Pause", forState: .Normal)
            //restart timer
            self.stopWatch.start()
            self.pauseButton.backgroundColor = kPauseButtonBackgroundColor
            
            
        default:
            println("ERROR: Yeeeeeee! pauseGpxTracking shall never be called with \(gpxTrackingStatus)")
        }
    
    }
    
    func startGpxTracking() {
        println("startGpxTracking::")
        switch gpxTrackingStatus {
        case .NotStarted:
            println("Not Started => initializing")
        case .Finished:
            println("Finish => RE initializing")
        default:
            println("ERROR: startGpxTracking")
        }
        self.stopWatch.reset()
        self.stopWatch.start()
        
        gpxTrackingStatus = .Tracking
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            self.startButton.hidden = true
            self.stopButton.hidden = false
            self.pauseButton.hidden = false
            }, completion: {(f: Bool) -> Void in
                println("finished animation start tracking")
            })
        
    }
    
    
    func stopGpxTracking() {
        println("stop GPX Tracking called")
        
        let alert = UIAlertView(title: "Save as", message: "Enter GPX session name", delegate: self, cancelButtonTitle: "Continue tracking")
        
        alert.addButtonWithTitle("Save")
        alert.addButtonWithTitle("Discard session")
        alert.alertViewStyle = .PlainTextInput;
        alert.tag = kSaveSessionAlertViewTag
        
        //set default file name -- discarded
        if self.lastLoadedSessionFilename.utf16Count > 0 {
            alert.textFieldAtIndex(0)?.text = self.lastLoadedSessionFilename
        }
        //let dateFormat = NSDateFormatter()
        //let now = NSDate()
        //dateFormat.dateStyle = NSDateFormatterStyle.MediumStyle
        //dateFormat.timeStyle = NSDateFormatterStyle.ShortStyle
        //alert.textFieldAtIndex(0)?.text = dateFormat.stringFromDate(now)
        alert.show();
        //alert.textFieldAtIndex(0)?.selectAll(self)
    }
    
    
    //UIAlertView Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        switch alertView.tag {
        case kSaveSessionAlertViewTag:
            
            println("alertViewDelegate for Save Session")
            switch buttonIndex {
            case 0: //cancel
                println("Finish canceled")
            case 2:
                //discard changes
                
                //hide stop and pause, and show start tracking ------
                gpxTrackingStatus = .Finished
                self.startButton.hidden = false
                self.stopButton.hidden = true
                self.pauseButton.hidden = true
                
                self.pauseButton.setTitle("Pause", forState: .Normal)
                self.pauseButton.backgroundColor = kPauseButtonBackgroundColor
                
                //Stop Timer
                stopWatch.stop()
                stopWatch.reset()
                self.timeLabel.text = stopWatch.elapsedTimeString
                
                self.map.clearMap()
            case 1:
                let filename = (alertView.textFieldAtIndex(0)?.text.utf16Count == 0) ? " " : alertView.textFieldAtIndex(0)?.text
                
                println("Save File \(filename)")
                
                //hide stop and pause, and show start tracking ---------
                gpxTrackingStatus = .Finished
                self.startButton.hidden = false
                self.stopButton.hidden = true
                self.pauseButton.hidden = true
            
                self.pauseButton.setTitle("Pause", forState: .Normal)
                self.pauseButton.backgroundColor = kPauseButtonBackgroundColor
            
                //Stop Timer
                stopWatch.stop()
                stopWatch.reset()
                self.timeLabel.text = stopWatch.elapsedTimeString
                
                //export to a file
                self.map.finishCurrentSegment()
                let gpxString = self.map.exportToGPXString()
                
                GPXFileManager.save(filename!, gpxContents: gpxString)
                //println(gpx.gpx())
                
                //clear tracks, pins and overlays
                self.map.clearMap()
                
            
            default:
            println("[ERROR] it seems there are more than two buttons on the alertview.")
        
            } //buttonIndex
        case kEditWaypointAlertViewTag:
            println("Edit waypoint alert view")
            self.waypointBeingEdited.title = alertView.textFieldAtIndex(0)?.text
            
        default:
            println("[ERROR] it seems that the AlertView is not handled properly." )
            
        }
    }
    
    
    //#pragma mark - location manager Delegate
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
         println("didFailWithError\(error)");
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
        
        let latFormat = String(format: "%.6f", newLocation.coordinate.latitude)
        let lonFormat = String(format: "%.6f", newLocation.coordinate.longitude)
        coordsLabel.text = "(\(latFormat),\(lonFormat))"
        if followUser {
            map.setCenterCoordinate(map.userLocation.coordinate, animated: true)
        }
        if gpxTrackingStatus == .Tracking {
            println("didUpdateLocation: adding point to track \(newLocation.coordinate)")
            map.addPointToCurrentTrackSegmentAtLocation(newLocation)
        }
        
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
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
    
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay is MKPolyline) {
            var pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.blueColor().colorWithAlphaComponent(0.5);
            pr.lineWidth = 3;
            return pr;
        }
        return nil
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        println("calloutAccesoryControlTapped ")
        let waypoint = view.annotation as GPXWaypoint
        let button = control as UIButton
        switch button.tag {
        case kDeleteWaypointAccesoryButtonTag:
            println("[calloutAccesoryControlTapped: DELETE button] deleting waypoint with name \(waypoint.name)");
            map.removeWaypoint(waypoint)
        case kEditWaypointAccesoryButtonTag:
            println("[calloutAccesoryControlTapped: EDIT] editing waypoint with name \(waypoint.name)")
            let alert = UIAlertView(title: "Edit Waypoint", message: "Hint: To change the waypoint location drag and drop the pin" , delegate: self, cancelButtonTitle: "Cancel")
            alert.addButtonWithTitle("Save")
            alert.tag = kEditWaypointAlertViewTag
            alert.alertViewStyle = .PlainTextInput;
            alert.textFieldAtIndex(0)?.text = waypoint.title
            alert.show();
            self.waypointBeingEdited = waypoint
            //alert.textFieldAtIndex(0)?.selectAll(self) //display text selected

        default:
            println("[calloutAccesoryControlTapped ERROR] unknown control")
        }
    }
    

    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if (newState == MKAnnotationViewDragState.Ending){
            let point = view.annotation as GPXWaypoint
            println("Annotation name: \(point.title) lat:\(point.latitude) lon \(point.longitude)")
        }
    }
    
    
    
    func mapView(mapView: MKMapView!, didAddAnnotationViews views: [AnyObject]!) {
        var i = 0
        for object in views {
            i++
            let aV = object as MKAnnotationView
            if aV.annotation.isKindOfClass(MKUserLocation) { continue }
            
            let point : MKMapPoint = MKMapPointForCoordinate(aV.annotation.coordinate)
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
        
        self.lastLoadedSessionFilename = gpxFilename
        
        //Set buttons ------------
        self.startButton.hidden = false
        self.stopButton.hidden = true
        self.pauseButton.hidden = true
        
        self.pauseButton.setTitle("Pause", forState: .Normal)
        self.pauseButton.backgroundColor = kPauseButtonBackgroundColor
        
        //Update watch
        self.stopWatch.stop()
        self.stopWatch.reset()
        self.timeLabel.text = stopWatch.elapsedTimeString
        
        self.map.importFromGPXRoot(gpxRoot)
        
    
        
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

