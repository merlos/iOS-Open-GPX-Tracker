//
//  UIDistanceLabel.swift
//  OpenGpxTracker
//
//  Created by merlos on 01/10/15.
//  Copyright © 2015 TransitBox. All rights reserved.
//

import Foundation
import UIKit
import MapKit

open class UIDistanceLabel: UILabel {
    
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
