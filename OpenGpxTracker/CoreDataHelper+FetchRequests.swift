//
//  CoreDataHelper+FetchRequests.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 1/8/20.
//

import CoreData
import CoreGPX

extension CoreDataHelper {
    
    func rootFetchRequest() -> NSAsynchronousFetchRequest<CDRoot> {
        let rootFetchRequest = NSFetchRequest<CDRoot>(entityName: "CDRoot")
        let asyncRootFetchRequest = NSAsynchronousFetchRequest(fetchRequest: rootFetchRequest) { asynchronousFetchResult in
            guard let rootResults = asynchronousFetchResult.finalResult else { return }
            
            DispatchQueue.main.async {
                guard let objectID = rootResults.last?.objectID else { self.lastFileName = ""; return }
                guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDRoot else { self.lastFileName = ""; return }
                self.lastFileName = safePoint.lastFileName ?? ""
                self.lastTracksegmentId = safePoint.lastTrackSegmentId
                self.isContinued = safePoint.continuedAfterSave
            }
        }
        return asyncRootFetchRequest
    }

    func trackPointFetchRequest() -> NSAsynchronousFetchRequest<CDTrackpoint> {
        // Creates a fetch request
        let trkptFetchRequest = NSFetchRequest<CDTrackpoint>(entityName: "CDTrackpoint")
        // Ensure that fetched data is ordered
        let sortTrkpt = NSSortDescriptor(key: "trackpointId", ascending: true)
        trkptFetchRequest.sortDescriptors = [sortTrkpt]
        
        // Creates `asynchronousFetchRequest` with the fetch request and the completion closure
        let asynchronousTrackPointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: trkptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable trackpoints from Core Data")
            
            guard let trackPointResults = asynchronousFetchResult.finalResult else { return }
            // Dispatches to use the data in the main queue
            DispatchQueue.main.async {
                self.tracksegmentId = trackPointResults.first?.trackSegmentId ?? 0
                
                for result in trackPointResults {
                    let objectID = result.objectID
                    
                    // thread safe
                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDTrackpoint else { continue }
                    
                    if self.tracksegmentId != safePoint.trackSegmentId {
                        if self.currentSegment.trackpoints.count > 0 {
                            self.tracksegments.append(self.currentSegment)
                            self.currentSegment = GPXTrackSegment()
                        }
                        
                        self.tracksegmentId = safePoint.trackSegmentId
                    }
                    
                    let pt = GPXTrackPoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    
                    pt.time = safePoint.time
                    pt.elevation = safePoint.elevation
                    
                    self.currentSegment.trackpoints.append(pt)
                    
                }
                self.trackpointId = trackPointResults.last?.trackpointId ?? Int64()
                self.tracksegments.append(self.currentSegment)
            }
        }
        
        return asynchronousTrackPointFetchRequest
    }
    
    func waypointFetchRequest() -> NSAsynchronousFetchRequest<CDWaypoint> {
        let wptFetchRequest = NSFetchRequest<CDWaypoint>(entityName: "CDWaypoint")
        let sortWpt = NSSortDescriptor(key: "waypointId", ascending: true)
        wptFetchRequest.sortDescriptors = [sortWpt]
        
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: wptFetchRequest) { asynchronousFetchResult in
            
            print("Core Data Helper: fetching recoverable waypoints from Core Data")
            
            // Retrieves an array of points from Core Data
            guard let waypointResults = asynchronousFetchResult.finalResult else { return }
            
            // Dispatches to use the data in the main queue
            DispatchQueue.main.async {
                for result in waypointResults {
                    let objectID = result.objectID
                    
                    // thread safe
                    guard let safePoint = self.appDelegate.managedObjectContext.object(with: objectID) as? CDWaypoint else { continue }
                    
                    let pt = GPXWaypoint(latitude: safePoint.latitude, longitude: safePoint.longitude)
                    
                    pt.time = safePoint.time
                    pt.desc = safePoint.desc
                    pt.name = safePoint.name
                    if safePoint.elevation != .greatestFiniteMagnitude {
                        pt.elevation = safePoint.elevation
                    }
                    
                    self.waypoints.append(pt)
                }
                
                self.waypointId = waypointResults.last?.waypointId ?? Int64()
                
                // trackpoint request first, followed by waypoint request
                // hence, crashFileRecovery method is ran in this.
                self.crashFileRecovery() // should always be in the LAST fetch request!
                print("Core Data Helper: async fetches complete.")
            }
        }
        
        return asynchronousWaypointFetchRequest
    }
    
}
