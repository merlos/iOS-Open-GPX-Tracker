//
//  CoreDataHelper.swift
//  OpenGpxTracker
//
//  Created by Vincent on 9/4/19.
//

import UIKit
import CoreData
import CoreGPX

/// Core Data implementation. As all Core Data related logic is contained here, I considered it as a helper.
///
/// Implementation learnt / inspired
/// from 4 part series:
/// https://marcosantadev.com/coredata_crud_concurrency_swift_1/
///
class CoreDataHelper {
    
    // tags to keep track of object's sequence
    var waypointId: Int64 = 0
    var trackpointId: Int64 = 0
    
    // app delegate.
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // arrays for handling retrieval of data when needed.
    var trackpoints = [GPXTrackPoint]()
    var waypoints = [GPXWaypoint]()
    
    // MARK:- Add to Core Data
    
    func add(toCoreData trackpoint: GPXTrackPoint) {
        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Creates the link between child and parent
        childManagedObjectContext.parent = appDelegate.managedObjectContext
        
        childManagedObjectContext.perform {
            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDTrackpoint", into: childManagedObjectContext) as! CDTrackpoint
            
            guard let elevation = trackpoint.elevation else { return }
            guard let latitude = trackpoint.latitude   else { return }
            guard let longitude = trackpoint.longitude else { return }
            
            pt.elevation = elevation
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = trackpoint.time
            pt.trackpointId = self.trackpointId
            
            // Serialization of trackpoint
            do {
                let serialized = try JSONEncoder().encode(trackpoint)
                pt.serialized = serialized
            }
            catch {
                print("Core Data Helper: serialization error when adding trackpoint: \(error)")
            }
            
            self.trackpointId += 1
            
            do {
                try childManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // Saves the data from the child to the main context to be stored properly
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding trackpoint: \(error)")
                    }
                }
            }
            catch {
                print("Failure to save child context when adding trackpoint: \(error)")
            }
        }
    }
    
    func add(toCoreData waypoint: GPXWaypoint) {
        let waypointChildManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Creates the link between child and parent
        waypointChildManagedObjectContext.parent = appDelegate.managedObjectContext
        
        waypointChildManagedObjectContext.perform {
            let pt = NSEntityDescription.insertNewObject(forEntityName: "CDWaypoint", into: waypointChildManagedObjectContext) as! CDWaypoint
            
            guard let latitude = waypoint.latitude   else { return }
            guard let longitude = waypoint.longitude else { return }
            
            pt.name = waypoint.name
            pt.desc = waypoint.desc
            pt.latitude = latitude
            pt.longitude = longitude
            pt.time = waypoint.time
            pt.waypointId = self.waypointId
            
            // Serialization of trackpoint
            do {
                let serialized = try JSONEncoder().encode(waypoint)
                pt.serialized = serialized
            }
            catch {
                print("Core Data Helper: serialization error when adding waypoint: \(error)")
            }
            
            self.waypointId += 1
            
            do {
                try waypointChildManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // Saves the data from the child to the main context to be stored properly
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save parent context when adding waypoint: \(error)")
                    }
                }
            }
            catch {
                print("Failure to save parent context when adding waypoint: \(error)")
            }
        }
    }
    
    func update(toCoreData updatedWaypoint: GPXWaypoint, from index: Int) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let wptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: updating waypoint in Core Data")
            
            // Retrieves an array of points from Core Data
            guard let waypointResults = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
            
            privateManagedObjectContext.perform {
                let objectID = waypointResults[index].objectID
                guard let pt = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { return }
                
                guard let latitude = updatedWaypoint.latitude   else { return }
                guard let longitude = updatedWaypoint.longitude else { return }
                
                pt.name = updatedWaypoint.name
                pt.desc = updatedWaypoint.desc
                pt.latitude = latitude
                pt.longitude = longitude
                
                do {
                    try privateManagedObjectContext.save()
                    self.appDelegate.managedObjectContext.performAndWait {
                        do {
                            // Saves the changes from the child to the main context to be applied properly
                            try self.appDelegate.managedObjectContext.save()
                        } catch {
                            print("Failure to update and save waypoint to parent context: \(error)")
                        }
                    }
                }
                catch {
                    print("Failure to update and save waypoint to context at child context: \(error)")
                }
            }
            
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch {
            print("NSAsynchronousFetchRequest (for finding updatable waypoint) error: \(error)")
        }
    }
    
    // MARK:- Retrieval From Core Data

    func retrieveFromCoreData() -> Bool {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        var isEmpty = false
        
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let trkptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTrackpoint")
        let wptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        // Ensure that fetched data is ordered 
        let sortTrkpt = NSSortDescriptor(key: "trackpointId", ascending: true)
        let sortWpt = NSSortDescriptor(key: "waypointId", ascending: true)
        trkptFetchRequest.sortDescriptors = [sortTrkpt]
        wptFetchRequest.sortDescriptors = [sortWpt]
        
        // Creates `asynchronousFetchRequest` with the fetch request and the completion closure
        let asynchronousTrackPointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: trkptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable trackpoints from Core Data")
            
            guard let trackPointResults = asynchronousFetchResult.finalResult as? [CDTrackpoint] else { return }
            // Dispatches to use the data in the main queue
            DispatchQueue.main.async {
                if trackPointResults.count == 0 {
                    isEmpty = true
                }
                else {
                    for result in trackPointResults {
                        let objectID = result.objectID
                        
                        // thread safe
                        guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDTrackpoint else { continue }
                        
                        let pt = GPXTrackPoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                        
                        pt.time = safePoint.time
                        pt.elevation = safePoint.elevation
                        
                        self.trackpoints.append(pt)
                        
                    }
                }
            }
        }
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable waypoints from Core Data")
            
            // Retrieves an array of points from Core Data
            guard let waypointResults = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
            
            // Dispatches to use the data in the main queue
            DispatchQueue.main.async {
                if waypointResults.count == 0 {
                    isEmpty = true
                }
                else {
                    for result in waypointResults {
                        let objectID = result.objectID
                        
                        // thread safe
                        guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { continue }
                        
                        let pt = GPXWaypoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                        
                        pt.time = safePoint.time
                        pt.desc = safePoint.desc
                        pt.name = safePoint.name
                        
                        self.waypoints.append(pt)
                    }
                }
                
                // trackpoint request first, followed by waypoint request
                // hence, crashFileRecovery method is ran in this.
                self.crashFileRecovery()
                print("async fetches complete.")
            }
        }
        
        do {
            // Executes two requests, one for trackpoint, one for waypoint.
            
            // Note: it appears that the actual object context execution happens after all of this, probably due to its async nature.
            try privateManagedObjectContext.execute(asynchronousTrackPointFetchRequest)
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (fetch request for recovery) error: \(error)")
        }
        return isEmpty
    }
    
    // MARK:- Delete from Core Data
    
    /// Delete Waypoint from index
    func deleteWaypoint(fromCoreDataAt index: Int) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let wptFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: delete waypoint from Core Data at index: \(index)")
            
            // Retrieves an array of points from Core Data
            guard let waypointResults = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
            
            privateManagedObjectContext.delete(waypointResults[index])
            
            do {
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
                print("Failure to save context at child context: \(error)")
            }
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (for finding deletable waypoint) error: \(error)")
        }
        
    }
    
    
    /// Delete all entities in Core Data
    func deleteAllFromCoreData() {
        
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        
        print("Core Data Helper: Batch Delete all from Core Data")
        
        // Creates a fetch request
        let trackpointFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDTrackpoint")
        let waypointFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CDWaypoint")
        
        if #available(iOS 9.0, *) {
            privateManagedObjectContext.perform {
                do {
                    let trackpointDeleteRequest = NSBatchDeleteRequest(fetchRequest: trackpointFetchRequest)
                    let waypointDeleteRequest = NSBatchDeleteRequest(fetchRequest: waypointFetchRequest)
                    
                    // execute both delete requests.
                    try privateManagedObjectContext.execute(trackpointDeleteRequest)
                    try privateManagedObjectContext.execute(waypointDeleteRequest)
                    
                    self.resetIds()
                    
                    try privateManagedObjectContext.save()
                    self.appDelegate.managedObjectContext.performAndWait {
                        do {
                            // Saves the changes from the child to the main context to be applied properly
                            try self.appDelegate.managedObjectContext.save()
                        } catch {
                            print("Failure to save context after delete: \(error)")
                        }
                    }
                }
                catch {
                    print("Failed to delete all from core data, error: \(error)")
                }
                
            }
            
        }
        else { // for pre iOS 9 (less efficient, load in memory before removal)
            let trackpointAsynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: trackpointFetchRequest) { asynchronousFetchResult in
                
                guard let results = asynchronousFetchResult.finalResult as? [CDTrackpoint] else { return }
                
                for result in results {
                    privateManagedObjectContext.delete(result)
                }
            }
            
            let waypointAsynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: waypointFetchRequest) { asynchronousFetchResult in
                
                guard let results = asynchronousFetchResult.finalResult as? [CDWaypoint] else { return }
                
                self.resetIds()
                
                for result in results {
                    privateManagedObjectContext.delete(result)
                }
            }
            
            do {
                // Executes all delete requests
                try privateManagedObjectContext.execute(trackpointAsynchronousFetchRequest)
                try privateManagedObjectContext.execute(waypointAsynchronousFetchRequest)
                try privateManagedObjectContext.save()
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // Saves the changes from the child to the main context to be applied properly
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context after delete: \(error)")
                    }
                }
                
            } catch let error {
                print("NSAsynchronousFetchRequest (for batch delete <iOS 9) error: \(error)")
            }
            // Fallback on earlier versions
        }
    }
    
    // MARK:- Reset & Clear
    
    /// Resets trackpoints and waypoints Id
    ///
    /// the Id is to ensure that when retrieving the entities, the order remains.
    /// This is important to ensure that the resulting recovery file has the correct order.
    func resetIds() {
        self.trackpointId = 0
        self.waypointId = 0
    }
    
    /// Clear all arrays after recovery.
    func clearArrays() {
        self.trackpoints = []
        self.waypoints = []
    }
    
    // MARK:- Packaging to file for recovery
    
    /// Handles actual file recovery.
    ///
    /// Adds all the 'recovered' content retrieved earlier to a recovered file.
    /// Deletes and clears core data stuff after file is successfully saved.
    func crashFileRecovery() {
        DispatchQueue.global().async {
            // checks if trackpoint and waypoint
            if self.trackpoints.count > 0 || self.waypoints.count > 0 {
                let root = GPXRoot(creator: kGPXCreatorString)
                let track = GPXTrack()
                let trackseg = GPXTrackSegment()
                
                trackseg.add(trackpoints: self.trackpoints)
                track.add(trackSegment: trackseg)
                root.add(track: track)
                root.add(waypoints: self.waypoints)
                
                let gpxString = root.gpx()
                
                // date format same as usual.
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
                
                // File name's date will be as of recovery time, not of crash time.
                let recoveredFileName = "recovery-\(dateFormatter.string(from: Date()))"
                
                // Save the recovered file.
                GPXFileManager.save(recoveredFileName, gpxContents: gpxString)
                print("File \(recoveredFileName) was recovered from previous session, prior to unexpected crash/exit")
                
                // once file recovery is completed, Core Data stored items are deleted.
                self.deleteAllFromCoreData()
                
                // once file recovery is completed, arrays are cleared.
                self.clearArrays()
            }
            else {
                // no recovery file will be generated if nothing is recovered (or did not crash).
            }
        }
       
    }
}
