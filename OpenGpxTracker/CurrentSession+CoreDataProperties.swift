//
//  CurrentSession+CoreDataProperties.swift
//  
//
//  Created by Vincent on 6/4/19.
//
//

import Foundation
import CoreGPX
import CoreData


extension CurrentSession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrentSession> {
        return NSFetchRequest<CurrentSession>(entityName: "CurrentSession")
    }

    @NSManaged public var trackpoint: GPXTrackPoint?
    //@NSManaged public var time: Date?
    //@NSManaged public var elevation: NSNumber?
    //@NSManaged public var latitude: NSNumber?
    //@NSManaged public var longitude: NSNumber?

}
