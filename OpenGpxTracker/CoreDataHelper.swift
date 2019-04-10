//
//  CoreDataHelper.swift
//  OpenGpxTracker
//
//  Created by Vincent on 9/4/19.
//

import UIKit
import CoreData
import CoreGPX

class CoreDataHelper: NSObject {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var trackpoints = [GPXTrackPoint]()
    var waypoints = [GPXWaypoint]()
    
    var trackpointsFetchComplete = false
    var waypointsFetchComplete = false
    
    /// from https://marcosantadev.com/coredata_crud_concurrency_swift_1/
    
    func add(toCoreData trackpoint: GPXTrackPoint) {
        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Creates the link between child and parent
        childManagedObjectContext.parent = appDelegate.managedObjectContext
        
        childManagedObjectContext.perform {
            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDTrackpoint", into: childManagedObjectContext) as! CDTrackpoint
            
            guard let elevation = trackpoint.elevation,
                let latitude = trackpoint.latitude,
                let longitude = trackpoint.longitude else { return }
            
            pt.elevation = elevation
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = trackpoint.time
            
            do {
                try childManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // Saves the data from the child to the main context to be stored properly
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func add(toCoreData waypoint: GPXWaypoint) {
        let waypointChildManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Creates the link between child and parent
        waypointChildManagedObjectContext.parent = appDelegate.managedObjectContext
        
        waypointChildManagedObjectContext.perform {
            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDWaypoint", into: waypointChildManagedObjectContext) as! CDWaypoint
            
            guard let elevation = waypoint.elevation,
                let latitude = waypoint.latitude,
                let longitude = waypoint.longitude else { return }
            
            pt.elevation = elevation
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = waypoint.time
            
            print("\(elevation) + \(latitude) + \(longitude)")
            
            do {
                try waypointChildManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // Saves the data from the child to the main context to be stored properly
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
            }
            catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    func retrieveFromCoreData() {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let trkptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTrackpoint")
        let wptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        // Creates `asynchronousFetchRequest` with the fetch request and the completion closure
        let asynchronousTrackPointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: trkptFetchRequest) { asynchronousFetchResult in
            
            print("fetching trackpoints from Core Data")
            
            // Retrieves an array of dogs from the fetch result `finalResult`
            guard let trackPointResults = asynchronousFetchResult.finalResult as? [CDTrackpoint] else { return }
            // Dispatches to use the data in the main queue
            DispatchQueue.main.async {
                for result in trackPointResults {
                    let objectID = result.objectID
                    
                    // thread safe
                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDTrackpoint else { continue }
                    
                    let pt = GPXTrackPoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    pt.time = safePoint.time
                    pt.elevation = safePoint.elevation
                    print(safePoint.latitude)
                    self.trackpoints.append(pt)
                    
                }
            }
        }
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("fetching waypoints from Core Data")
            
            // Retrieves an array of dogs from the fetch result `finalResult`
            guard let waypointResults = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
            // Dispatches to use the data in the main queue
            DispatchQueue.main.async {
                for result in waypointResults {
                    let objectID = result.objectID
                    
                    // thread safe
                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { continue }
                    
                    let pt = GPXWaypoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    pt.time = safePoint.time
                    pt.elevation = safePoint.elevation
                    print(safePoint.latitude)
                    self.waypoints.append(pt)
                }
                self.crashFileRecovery()
            }
        }
        
        print("rec-waypoint count: \(self.waypoints.count)")
        print("rec-trackpoint count: \(self.trackpoints.count)")
        
        
        do {
            // Executes `asynchronousFetchRequest`
            try privateManagedObjectContext.execute(asynchronousTrackPointFetchRequest)
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
            
            //addObserver(self, forKeyPath: #keyPath(privateManagedObjectCo), options: , context: )
            
            print("DO rec-waypoint count: \(self.waypoints.count)")
            print("DO rec-trackpoint count: \(self.trackpoints.count)")
            print("async fetches complete.")
        } catch let error {
            print("NSAsynchronousFetchRequest error: \(error)")
        }
    }
    
    func deleteAllFromCoreData() {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
        if #available(iOS 9.0, *) {
            privateManagedObjectContext.perform {
                do {
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try privateManagedObjectContext.execute(deleteRequest)
                    try privateManagedObjectContext.save()
                    self.appDelegate.managedObjectContext.performAndWait {
                        do {
                            // Saves the changes from the child to the main context to be applied properly
                            try self.appDelegate.managedObjectContext.save()
                        } catch {
                            print("Failure to save context: \(error)")
                        }
                    }
                }
                catch {
                    print("failed to delete all: error: \(error)")
                }
                
            }
            
        }
        else { // for pre iOS 9 (less efficient, load in mem before removal)
            let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { asynchronousFetchResult in
                
                // Retrieves an array of dogs from the fetch result `finalResult`
                guard let results = asynchronousFetchResult.finalResult as? [Point] else { return }
                
                for result in results {
                    privateManagedObjectContext.delete(result)
                }
            }
            do {
                // Executes `asynchronousFetchRequest`
                try privateManagedObjectContext.execute(asynchronousFetchRequest)
            } catch let error {
                print("NSAsynchronousFetchRequest error: \(error)")
            }
            // Fallback on earlier versions
        }
    }
    
    func clearArrays() {
        self.trackpoints = []
        self.waypoints = []
    }
    
    func crashFileRecovery() {
        DispatchQueue.global().async {
            if self.trackpoints.count > 0 || self.waypoints.count > 0 {
                let root = GPXRoot(creator: kGPXCreatorString)
                let track = GPXTrack()
                let trackseg = GPXTrackSegment()
                
                trackseg.add(trackpoints: self.trackpoints)
                track.add(trackSegment: trackseg)
                root.add(track: track)
                root.add(waypoints: self.waypoints)
                
                let gpxString = root.gpx()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
                
                /// File name's date will be as of recovery.
                let recoveredFileName = "recovery-\(dateFormatter.string(from: Date()))"
                
                GPXFileManager.save(recoveredFileName, gpxContents: gpxString)
                print("File \(recoveredFileName) was recovered from last crashed session")
                
                // once file recovery is completed, Core Data stored items are deleted.
                self.deleteAllFromCoreData()
                
                // once file recovery is completed, arrays are cleared.
                self.clearArrays()
            }
            else {
                // recovery file will not be if no trackpoints
            }
        }
       
    }
}
