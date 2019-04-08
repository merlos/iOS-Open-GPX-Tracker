//
//  GPXType.swift
//  GPXKit
//
//  Created by Vincent on 2/11/18.
//
//

import Foundation

/**
    For conversion of values when required.
 
    Conversion of values may not always be done strictly using this class, as some of the methods here might be unoptimised, and may contain code carried over from the legacy code.
 
    - Note: This class is intended to be internally used only.
 */
class GPXType: NSObject {
    
    /// for use in conversion from `Double` of latitude to `String`
    ///
    /// - Parameters:
    ///     - latitude: input value must be valid within -90.0 and 90.0;
    /// In the case where input value exceeds range, 0 is returned
    ///
    @available(*, deprecated, message: "method is no longer used and will be unsupported in future")
    func value(forLatitude latitude: Double) -> String {
        if -90.0 <= latitude && latitude <= 90.0 {
            return String(format: "%f", latitude)
        }
        else {
            return "0"
        }
    }
    
    /// for use in conversion from `Double` of longitude to `String`
    ///
    /// - Parameters:
    ///     - longitude: input value must be valid within -180.0 and 180.0;
    /// In the case where input value exceeds range, 0 is returned
    ///
    @available(*, deprecated, message: "method is no longer used and will be unsupported in future")
    func value(forLongitude longitude: Double) -> String {
        if -180.0 <= longitude && longitude <= 180.0 {
            return String(format: "%f", longitude)
        }
        else {
            return "0"
        }
    }
    
    /// for converting a `String` value to `GPXFix` enum
    func fix(value: String) -> GPXFix {
        
        if value == "2D" {
            return .TwoDimensional
        }
        else if value == "3D" {
            return .ThreeDimensional
        }
        else if value == "dgps" {
            return .Dgps
        }
        else if value == "pps" {
            return .Pps
        }
        else {
            return .none
        }
        
    }
    
    /// for conversion from enum `GPXFix` to `String`
    func value(forFix fix: GPXFix) -> String {
        switch fix {
            case .none:             return "none"
            case .TwoDimensional:   return "2D"
            case .ThreeDimensional: return "3D"
            case .Dgps:             return "dgps"
            case .Pps:              return "pps"
        }
    }
    
    /// for conversion from an optional `String` of DGPS station to `Int`
    ///
    /// - Parameters:
    ///     - value: `String` type should be a number within 0 and 1023; will return 0 when out of range.
    ///
    func dgpsStation(_ value: String?) -> Int {
        let i = Int(value ?? "") ?? 0
        if 0 <= i && i <= 1023 {
            return i
        }
        else {
            return 0
        }
    }
    
    /// for conversion from `Int` of DGPS station to `String`
    ///
    /// - Parameters:
    ///     - dgpsStation: `Int` should be within 0 and 1023; will return 0 when out of range.
    ///
    func value(forDgpsStation dgpsStation: Int) -> String {
        if 0 <= dgpsStation && dgpsStation <= 360 {
            return String(format: "%ld", Int32(dgpsStation))
        }
        else {
            return "0"
        }
    }
    
    /// for conversion of date and time formatted as per ISO8601 standards of `String` type to `Date`
    ///
    /// - Parameters:
    ///      - value: date and time formatted string
    ///
    /// This method has not been used much as it was intended for GPX parsing, but as `DateFormatter` was not fast enough, this method has not been used often.
    ///
    @available(*, deprecated, message: "Use class ISO8601DateParser instead.")
    func dateTime(value: String) -> Date? {
        let formatter = DateFormatter()
        
        // date formatter's time zone should always be in UTC time as GPX schema explictly requires time to not be in local time.
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // dateTime（YYYY-MM-DDThh:mm:ssZ)
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        if let date = formatter.date(from: value) {
            return date
        }
        
        // dateTime（YYYY-MM-DDThh:mm:ss.SSSZ）
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        if let date = formatter.date(from: value) {
            return date
        }
        
        // dateTime（YYYY-MM-DDThh:mm:sszzzzzz)
        if value.count >= 22 {
            formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'sszzzz"
            let v = (value as NSString).replacingOccurrences(of: ":", with: "", options: [], range: NSMakeRange(22, 1))
            if let date = formatter.date(from: v) {
                return date
            }
        }
        
        // date
        formatter.dateFormat = "yyyy'-'MM'-'dd'"
        if let date = formatter.date(from: value) {
            return date
        }
        
        // gYearMonth
        formatter.dateFormat = "yyyy'-'MM'"
        if let date = formatter.date(from: value) {
            return date
        }
        
        // gYear
        formatter.dateFormat = "yyyy'"
        if let date = formatter.date(from: value) {
            return date
        }
        
        return nil
        
    }
    
    /// facilitates conversion from optional `Date` to optional `String`
    ///
    /// - Parameters:
    ///     - date: can be of any date and time, which will be converted to a formatted ISO8601 date and time string.
    ///
    /// - Returns:
    ///     Formatted string according to ISO8601, which is of **"yyyy-MM-ddTHH:mm:ssZ"**
    ///
    /// This method is currently heavily used for generating of GPX files / formatted string, as the native `Date` type must be converted to a `String` first.
    ///
    @available(*, deprecated, message: "Use class Convert instead.")
    func value(forDateTime date: Date?) -> String? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // dateTime（YYYY-MM-DDThh:mm:ssZ）
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        
        guard let validDate = date else {
            return nil
        }
        
        return formatter.string(from: validDate)
    }
    
    /// conversion of `String` to `Int`
    ///
    /// - Parameters:
    ///     - string: must be a number, above 0.
    ///
    /// - Returns: a non negative integer. (positive only)
    ///
    func nonNegativeInt(_ string: String) -> Int {
        if let i = Int(string) {
            if i >= 0 {
                return i
            }
        }
        return 0
    }
    
    /// conversion of `Int` to `String`
    ///
    /// - Parameters:
    ///     - int: must be above 0. (cannot be negative)
    ///
    /// - Returns: a non negative number formatted as `String`. (positive only)
    ///
    func value(forNonNegativeInt int: Int) -> String {
        if int >= 0 {
            return String(format: "%ld", Int32(int))
        }
        return "0"
    }
    
}

/// Carried forward from legacy code
///
/// - Note:
///     I believe this enum may not be useful as `CoreLocation` API does not appear to state GPS Fix type.
enum GPXFix: Int {
    
    /// No Fix
    case none = 0
    
    /// 2D Fix, position only.
    case TwoDimensional
    
    /// 3D Fix, position and elevation.
    case ThreeDimensional
    
    /// Differencial GPS fix
    case Dgps
    
    /// Military GPS-equivalent
    case Pps
}
