//
//  CLLocation+accuracy.swift
//  OpenGpxTracker
//
//  Created by Alan Heezen on 8/12/20.
//

import Foundation
import CoreLocation

extension CLLocation {  // This is a hybrid for trial, adjusted to be comparable to .horizontalAccuracy
    func accuracy() -> Double {
        return sqrt( self.horizontalAccuracy * self.horizontalAccuracy
            + self.verticalAccuracy * self.verticalAccuracy) * 0.857 // =6/7
    }
}
extension CLLocation {
    func accuracyEllipsoid() -> Double {
        return sqrt((self.horizontalAccuracy * self.horizontalAccuracy * 2.0) / 3.0
            + (self.verticalAccuracy * self.verticalAccuracy) * 25 / 27.0)
    }
}
extension CLLocation {
    func accuracy3D() -> Double {
        return sqrt( self.horizontalAccuracy * self.horizontalAccuracy * 2.0
            + self.verticalAccuracy * self.verticalAccuracy)
    }
}
extension CLLocation {
    func accuracy1D() -> Double {
        return self.horizontalAccuracy
    }
}
