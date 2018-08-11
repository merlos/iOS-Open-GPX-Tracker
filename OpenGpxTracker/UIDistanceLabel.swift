//
//  UIDistanceLabel.swift
//  OpenGpxTracker
//
//  Created by merlos on 01/10/15.
//

import Foundation
import UIKit
import MapKit

///
/// A label to display distances.
///
/// The text is displated in meters if is less than 1km (for instance "980m") and in km with two decimals if
/// it is larger than 1km (for instance "1.20km")
///
/// To update the text displayed use the distance variable.
///
open class UIDistanceLabel: UILabel {
    
    /// Distance in meters
    open var distance: CLLocationDistance {
        get {
            return 0
        }
        set {
            if newValue > 1000.0 { //use km
                let formatted = String(format: "%.2f", (newValue/1000.0))
                self.text = "\(formatted)km"
            } else {
                let formatted = String(format: "%.0f", (newValue))
                self.text = "\(formatted)m"
            }
        }
    }
}
