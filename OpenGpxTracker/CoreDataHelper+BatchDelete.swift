//
//  CoreDataHelper+BatchDelete.swift
//  OpenGpxTracker
//
//  Created by Vincent on 1/8/20.
//

import CoreData

extension CoreDataHelper {
    
    @available(iOS 10.0, *)
    func modernBatchDelete<T: NSManagedObject>(of type: T.Type) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        
        privateManagedObjectContext.perform {
            do {
                let name = "\(T.self)" // Generic name of the object is the entityName
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                // execute delete request.
                try privateManagedObjectContext.execute(deleteRequest)
                
                try privateManagedObjectContext.save()
                
                self.appDelegate.managedObjectContext.performAndWait {
                    do {
                        // Saves the changes from the child to the main context to be applied properly
                        try self.appDelegate.managedObjectContext.save()
                    } catch {
                        print("Failure to save context after delete: \(error)")
                    }
                }
            } catch {
                print("Failed to delete all from core data, error: \(error)")
            }
            
        }
    }
    
    func legacyBatchDelete<T: NSManagedObject>(of type: T.Type) {
        let privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.parent = appDelegate.managedObjectContext
        // Creates a fetch request
        let fetchRequest = NSFetchRequest<T>(entityName: "\(T.self)")
        fetchRequest.includesPropertyValues = false
        let asynchronousWaypointFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { asynchronousFetchResult in
            
            // Retrieves an array of points from Core Data
            guard let results = asynchronousFetchResult.finalResult else { return }
            
            for result in results {
                privateManagedObjectContext.delete(result)
            }
            
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
            } catch {
                print("Failure to save context at child context: \(error)")
            }
        }
        
        do {
            try privateManagedObjectContext.execute(asynchronousWaypointFetchRequest)
        } catch let error {
            print("NSAsynchronousFetchRequest (while deleting \(T.self) error: \(error)")
        }

    }
}
