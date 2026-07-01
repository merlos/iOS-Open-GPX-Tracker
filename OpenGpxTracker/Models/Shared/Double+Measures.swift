//
//  Double+Meatures.swift
//  OpenGpxTracker
//
//  Created by merlos on 03/05/2019.
//
// Shared file: this file is also included in the OpenGpxTracker-Watch Extension target.

import Foundation

/// Number of meters in 1 mile (mi)
let kMetersPerMile = 1609.344

/// Number of meters in 1 kilometer (km)
let kMetersPerKilometer = 1000.0

/// Number of meters in 1 feet (ft)
let kMetersPerFeet = 0.3048

/// Number of kilometers per hour in 1 meter per second
/// To convert m/s -> km/h
let kKilometersPerHourInOneMeterPerSecond = 3.6

/// Number of miles per hour in 1 meter per second
/// To convert m/s -> mph
let kMilesPerHourInOneMeterPerSecond = 2.237

/// Number of miles per hour in 1 meter per second
///
/// Extension to convert meters to other units
///
/// It was created to support conversion of units also in iOS9
///
/// (UnitConverterLinear)[https://developer.apple.com/documentation/foundation/unitlength#overview]
/// is available only in iOS 10 or above.
///
/// It always asumes the value in meters (lengths) or meters per second (speeds)
extension Double {
    
    /// Assuming current value is in meters, it returns the equivalent in feet
    func toFeet() -> Double {
        return self/kMetersPerFeet
    }
    
    /// Assuming current value is in meters, it returns the equivalent string in feet without decimals and with "ft"
    func toFeet() -> String {
        return String(format: "%.0fft", self.toFeet() as Double)
    }
    
    /// Assuming current value is in meters, it returns the equivalent in miles
    func toMiles() -> Double {
        return self/kMetersPerMile
    }
    
    /// Assuming current value is in meters, it returns the equivalent string
    /// in miles with two decimals and "mi"
    ///
    /// - Example:
    ///
    ///         Double d = 1609.344
    ///         d.toMilesString() => "1.00mi"
    ///
    func toMiles() -> String {
        return String(format: "%.2fmi", toMiles() as Double)
    }
    
    /// Assuming current value is in meters, it returns the equivalent in kilometers
    func toKilometers() -> Double {
        return self/kMetersPerKilometer
    }
    
    /// Assuming current value is in meters, it returns a string wiht the equivalent in
    /// kilometers with two decimals and km
    ///
    /// Example: Current value is 1210.0, it returns "1.21km"
    func toKilometers() -> String {
        return String(format: "%.2fkm", toKilometers() as Double)
    }
    
    /// Returns current value as a string without decimals and with m.
    ///
    /// Example: Current value is 1210.13, it returns "1210m"
    func toMeters() -> String {
        return String(format: "%.0fm", self)
    }
    
    /// Assuming current value (d) is in meters it returns the distance as string
    /// * if d < 1000 => in meters ("567m")
    /// * if d > 1000 => in kilometers ("1.24km")
    /// * if useImperial == true => converted in miles ("1.24mi")
    func toDistance(useImperial: Bool = false) -> String {
        if useImperial {
            return toMiles() as String
        } else {
            return self > kMetersPerKilometer ? toKilometers() as String : toMeters() as String
        }
    }
    
    /// Assuming current value is a speed in meters per second (m/s),
    ///
    /// - Returns:
    ///     The speed in miles per hour (mph)
    func toMilesPerHour() -> Double {
        return self * kMilesPerHourInOneMeterPerSecond
    }
    
    /// Assuming current value is a speed in meters per second (m/s),
    ///
    /// - Returns:
    ///     The speed in miles per hour (mph) with two decimals as
    /// string ("120.34mph")
    func toMilesPerHour() -> String {
        return String(format: "%.2fmph", toMilesPerHour() as Double)
    }
    
    /// Assuming current value is a speed in meters per second (m/s),
    ///
    /// - Returns:
    ///     The speed in kilometers per hour (km/h)
    func toKilometersPerHour() -> Double {
        return self * kKilometersPerHourInOneMeterPerSecond
    }
    
    /// Assuming current value is a speed in meters per second (m/s),
    ///
    /// - Returns:
    ///     The speed in kilometers per hour with two decimals as
    /// string  ("120.34km/h")
    func toKilometersPerHour() -> String {
        return String(format: "%.2fkm/h", toKilometersPerHour() as Double)
    }
    
    /// Assuming current value is a speed in meters per second (m/s),
    ///
    /// - Returns:
    ///     The speed in km/h (100.00km/h) or mph (60.00mph) if `useImperial` is set to `true`.
    func toSpeed(useImperial: Bool = false) -> String {
        return useImperial ? toMilesPerHour() : toKilometersPerHour() as String
    }
    
    /// Asuming current value is an altitud in meters,
    ///
    /// - Returns:
    ///     The altitude in m ("100m") or in feet (304ft) if `useImperial` is set to `true`.
    func toAltitude(useImperial: Bool = false) -> String {
        return useImperial ? toFeet() : toMeters() as String
    }
    
    /// Asuming current value is an altitud in meters,
    ///
    /// - Returns:
    ///     The altitude in m ("±100m") or in feet (±304ft) if `useImperial` is set to `true`.
    func toAccuracy(useImperial: Bool = false) -> String {
        return "±\(useImperial ? toFeet() as String : toMeters() as String)"
    }

}
