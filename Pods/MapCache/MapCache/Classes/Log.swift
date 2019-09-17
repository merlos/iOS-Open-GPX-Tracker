//
//  Log.swift
//  MapCache
//
//  Created by merlos on 02/06/2019.
//
// Based on Haneke' Log File
// https://github.com/Haneke/HanekeSwift/blob/master/Haneke/Log.swift
//


import Foundation


struct Log {
    
    fileprivate static let Tag = "[MAPCACHE]"
    
    fileprivate enum Level : String {
        case Debug = "[DEBUG]"
        case Error = "[ERROR]"
    }
    
    fileprivate static func log(_ level: Level, _ message: @autoclosure () -> String, _ error: Error? = nil) {
        if let error = error {
            print("\(Tag)\(level.rawValue) \(message()) with error \(error)")
        } else {
            print("\(Tag)\(level.rawValue) \(message())")
        }
    }
    
    static func debug(message: @autoclosure () -> String, error: Error? = nil) {
        #if DEBUG
        log(.Debug, message(), error)
        #endif
    }
    
    static func error(message: @autoclosure () -> String, error: Error? = nil) {
        log(.Error, message(), error)
    }
    
}
