//
//  GPXWaypoint+Comparison.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 2/1/20.
//

import CoreGPX

infix operator =~

extension GPXWaypoint {
    
    static func =~ (wpt1: GPXWaypoint, wpt2: GPXWaypoint) -> Bool {
        if wpt1.latitude    ==      wpt2.latitude
        && wpt1.longitude   ==      wpt2.longitude
        //&& wpt1.elevation   ==      wpt2.elevation
        && wpt1.time        ==      wpt2.time
        //&& wpt1.name        ==      wpt2.name
        && wpt1.desc        ==      wpt2.desc
        {
            return true
        }
        else {
            return false
        }
    }
}
