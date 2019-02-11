//
//  WKDistanceLabel.swift
//  OpenGpxTracker-Watch Extension
//
//  Created by Vincent on 11/2/19.
//  Copyright © 2019 TransitBox. All rights reserved.
//

import WatchKit
import MapKit

///
/// A label to display distances.
///
/// The text is displated in meters if is less than 1km (for instance "980m") and in km with two decimals if
/// it is larger than 1km (for instance "1.20km")
///
/// To update the text displayed use the distance variable.
///

class WKDistanceText {
    /// Distance in meters
    open var distance: CLLocationDistance {
        get {
            return 0
        }
        set {
            if newValue > 1000.0 { //use km
                let formatted = String(format: "%.2f", (newValue/1000.0))
                //self.setText("\(formatted)km")
                formattedText = "\(formatted)km"
            } else {
                let formatted = String(format: "%.0f", (newValue))
                formattedText = "\(formatted)m"
            }
        }
    }
    open var formattedText = String()
}
