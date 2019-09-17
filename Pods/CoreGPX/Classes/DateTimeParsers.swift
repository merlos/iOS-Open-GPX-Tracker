//
//  GPXDateTime.swift
//  CoreGPX
//
//  Created on 23/3/19.
//
//  Original code from: http://jordansmith.io/performant-date-parsing/
//  Modified to better suit CoreGPX's functionalities.
//

import Foundation

/**
 Date Parser for use when parsing GPX files, containing elements with date attributions.
 
 It can parse ISO8601 formatted date strings, along with year strings to native `Date` types.
 
 Formerly Named: `ISO8601DateParser` & `CopyrightYearParser`
 */
final class GPXDateParser {
    
    // MARK:- Supporting Variables
    
    /// Caching Calendar such that it can be used repeatedly without reinitializing it.
    private static var calendarCache = [Int : Calendar]()
    /// Components of Date stored together
    private static var components = DateComponents()
    
    // MARK:- Individual Date Components
    
    private static let year = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let month = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let day = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let hour = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let minute = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    private static let second = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    
    // MARK:- String To Date Parsers
    
    /// Parses an ISO8601 formatted date string as native Date type.
    static func parse(date string: String?) -> Date? {
        guard let NonNilString = string else {
            return nil
        }
        
        _ = withVaList([year, month, day, hour, minute,
                        second], { pointer in
                            vsscanf(NonNilString, "%d-%d-%dT%d:%d:%dZ", pointer)
                            
        })
        
        components.year = year.pointee
        components.minute = minute.pointee
        components.day = day.pointee
        components.hour = hour.pointee
        components.month = month.pointee
        components.second = second.pointee
        
        if let calendar = calendarCache[0] {
            return calendar.date(from: components)
        }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendarCache[0] = calendar
        return calendar.date(from: components)
    }
    
    /// Parses a year string as native Date type.
    static func parse(year string: String?) -> Date? {
        guard let NonNilString = string else {
            return nil
        }
        
        _ = withVaList([year], { pointer in
            vsscanf(NonNilString, "%d", pointer)
            
        })
        
        components.year = year.pointee
        
        if let calendar = calendarCache[1] {
            return calendar.date(from: components)
        }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendarCache[1] = calendar
        return calendar.date(from: components)
    }
}
