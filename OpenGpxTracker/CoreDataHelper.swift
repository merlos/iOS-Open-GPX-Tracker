//
//  CoreDataHelper.swift
//  OpenGpxTracker
//
//  Created by Vincent on 9/4/19.
//

import UIKit
import CoreData
import CoreGPX

class CoreDataHelper {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// from https://marcosantadev.com/coredata_crud_concurrency_swift_1/
    
    func add(toCoreData trackpoint: GPXTrackPoint) {
        let childManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Creates the link between child and parent
        childManagedObjectContext.parent = appDelegate.managedObjectContext
        
        childManagedObjectContext.perform {
            let pt = NSEntityDescription.insertNewObject(forEntityName: "Point", into: childManagedObjectContext) as! Point
            
            guard let elevation = trackpoint.elevation,
                let latitude = trackpoint.latitude,
                let longitude = trackpoint.longitude else { return }
            
            pt.type = "trackpoint"
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
    
    func retrieveFromCoreData() {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Point")
        
        // Creates `asynchronousFetchRequest` with the fetch request and the completion closure
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { asynchronousFetchResult in
            
            // Retrieves an array of dogs from the fetch result `finalResult`
            guard let results = asynchronousFetchResult.finalResult as? [Point] else { return }
            // Dispatches to use the data in the main queue
            DispatchQueue.main.async {
                var points = [Point]()
                var trackpoints = [GPXTrackPoint]()
                var waypoints = [GPXWaypoint]()
                for result in results {
                    let objectID = result.objectID
                    
                    guard let safeObject = self.appDelegate.managedObjectContext.object(with: objectID) as? Point else { continue }
                    
                    points.append(safeObject)
                }
                
                for point in points {
                    if point.type == "trackpoint" {
                        let pt = GPXTrackPoint(latitude: point.latitude, longitude: point.longitude)
                        pt.time = point.time
                        pt.elevation = point.elevation
                        trackpoints.append(pt)
                    }
                    if point.type == "waypoint" {
                        let pt = GPXWaypoint(latitude: point.latitude, longitude: point.longitude)
                        pt.time = point.time
                        pt.elevation = point.elevation
                        waypoints.append(pt)
                    }
                }
                self.crashFileRecovery(include: trackpoints, waypoints: waypoints)
            }
        }
        
        do {
            // Executes `asynchronousFetchRequest`
            try privateManagedObjectContext.execute(asynchronousFetchRequest)
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
    
    func crashFileRecovery(include trackpoints: [GPXTrackPoint], waypoints: [GPXWaypoint]) {
        if trackpoints.count > 0 || waypoints.count > 0 {
            let root = GPXRoot(creator: kGPXCreatorString)
            let track = GPXTrack()
            let trackseg = GPXTrackSegment()
            
            trackseg.add(trackpoints: trackpoints)
            track.add(trackSegment: trackseg)
            root.add(track: track)
            
            let gpxString = root.gpx()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy-HHmm"
            
            /// File name's date will be as of recovery.
            let recoveredFileName = "recovery-\(dateFormatter.string(from: Date()))"
            
            GPXFileManager.save(recoveredFileName, gpxContents: gpxString)
            
            // once file recovery is completed, Core Data trackpoints are deleted.
            deleteAllFromCoreData()
        }
        else {
            // recovery file will not be if no trackpoints
        }
    }
}
