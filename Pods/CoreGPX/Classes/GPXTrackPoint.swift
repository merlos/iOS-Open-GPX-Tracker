//
//  GPXTrackPoint.swift
//  GPXKit
//
//  Created by Vincent on 9/12/18.
//

import UIKit

open class GPXTrackPoint: GPXWaypoint {
    
    public required init() {
        super.init()
    }
    
    // MARK:- Instance
    
    public override init(latitude: CGFloat, longitude: CGFloat) {
        super.init()
    }
    
    // MARK:- Tag
    
    override func tagName() -> String! {
        return "trkpt"
    }

}
