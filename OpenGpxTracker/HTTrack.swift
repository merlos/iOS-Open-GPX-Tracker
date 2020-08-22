//
//  HTTrack.swift
//  OpenGpxTracker
//
//  Created by Alan Heezen on 8/6/20.

//The primary purpose of an instance of this class is to intercept each CLLocation
//provided by a LocationManager and decide what, if anything to pass on to the
//MapView. Using the raw data from any GPS produces tracks that are much too noisy
//and this noise is integrated into the track and especially into the total
//length.
//
//It uses four strategies for this decision.
//
//(1) Spacing - GPX Tracker spaces the points by setting the Location Manager's
//distance filter to 2 meters. This is a start but a case can be made that one has
//to get a position change of at least twice the horizontal accuracy in order to
//be reasonably certain that the user has moved at all. My new iPhone Xr ususally
//settles into an accuracy of 5 meters so the distance filter, if used at all,
//should be set closer to 10 meters. Or more.
//
//(2) Smoothing - Just changing the distance filter helps, especially with the
//track length, but that change alone produces tracks which are still
//unrealistically jagged even when walking in a straight line. The Aggregator
//class gathers and averages raw location data and reports its progress back to
//the HTTrack, which decides when to accept the new aggregated point.
//
//The above strategies have been included in my fork of GPX Tracker, called
//TrackerHT for now. The last two have been tested in my own app but are not yet
//ported to GPX Tracker, for various reasons.
//
//(3) Sharp corners - The two strategies above will, in relatively rare instances,
//cause the recorded track to round off very sharp turns (like mountain
//switchbacks). I find this to be tolerable but I have a feature that allows the
//user to override and force the current reading to be added to the track. That
//sharpens up the corners nicely but requires operator intervention.
//
//(3) Pedometer - Large errors can be introduced when the hiker stops, since the
//GPS is terrible at deciding when the user is standing still. I have seen devices
//add on as much as half a mile to the track while I was sitting down having
//lunch. I've introduced CoreMotion to prevent the inclusion of new points when
//the user is not walking - of course, this has to be disabled for bike riding and
//some other activities.
//
//There are a lot of things to talk about here! Aside from my added files I have
//only modified ViewController.swift in a few places, which I've marked.
//

import Foundation
import CoreLocation

// An implementation of SmoothTrack.swift to be merged into Open GPX Tracker

var grossErrorBound = 15.0
var spacingFactor = 1.0
var saveNextPoint: Bool = false

class HTTrack {
    private var previousLocation: CLLocation?
    private var aggregator: HTAggregator?
    
    public func filtered(_ rawLocation: CLLocation) -> CLLocation? {
        if previousLocation == nil { // New track - wait for a reading with decent accuracy
            if rawLocation.accuracy() < grossErrorBound {
                previousLocation = rawLocation
                aggregator = HTAggregator()
                return rawLocation // pass it on to the map
            } else {
                return nil
            }
        } else {
            if saveNextPoint {
                // This won't occur until I find a way to handle this feature in the VC
                // ¿¿ Do a reach-around, slipping the aggregated point into the map
                // and returning the rawLocation to be processed by the VC??
                // Another possibility would be to return an array and loop through it in the VC
                // map.addPointToCurrentTrackSegmentAtLocation(aggregator.evaluate)
                // also start a new aggregator
                saveNextPoint = false
                return rawLocation
            } else {
                if aggregator!.add(rawLocation) >= spacingFactor * rawLocation.accuracy() {
                    let filteredLocation = aggregator?.evaluate()
                    aggregator = HTAggregator()
                    return filteredLocation
                }
            }
        }
        return nil // can't get here
    }
    
    public func reinit() {
        previousLocation = nil
        aggregator = nil
    }
}
