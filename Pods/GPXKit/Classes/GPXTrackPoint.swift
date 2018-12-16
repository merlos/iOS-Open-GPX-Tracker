//
//  GPXTrackPoint.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

open class GPXTrackPoint: GPXWaypoint {
    
    // MARK:- Instance
    
    func trackpointWith(latitude: CGFloat, longitude: CGFloat) -> GPXTrackPoint {
        let trackpoint = GPXTrackPoint()
        
        trackpoint.latitude = latitude
        trackpoint.longitude = longitude
        
        return trackpoint
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "trkpt"
    }

}
