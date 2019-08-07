//
//  DistanceLabel.swift
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
/// The text is displated in meters if is less than 1km (for instance "980m") and in
/// km with two decimals if it is larger than 1km (for instance "1.20km").
///
/// If `useImperial` is true, it displays the distance always in miles ("0.23mi").
///
/// To update the text displayed set the `distance` property.
///
open class DistanceLabel: UILabel {
    
    /// Internal variable that keeps the actual distance
    private var _distance = 0.0
    
    ///Internal variable to keep the use of imperial units
    private var _useImperial = false
    
    /// Use imperial units (miles)? False by default.
    /// If true, displays meters and kilometers
    open var useImperial: Bool {
        get {
            return _useImperial
        }
        set {
            _useImperial = newValue
            distance = _distance //updates text displayed to reflect the new units
        }
    }
    
    /// Distance in meters
    open var distance: CLLocationDistance {
        get {
            return _distance
        }
        set {
            _distance = newValue
            text = newValue.toDistance(useImperial: _useImperial)
        }
    }
}
