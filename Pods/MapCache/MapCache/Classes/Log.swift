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

///
/// For logging messages on console.
///
/// The log format is `<tag><Level> <message> [with error <error>]`:
/// Examples:
/// ```
///   [MapCache][DEBUG] Welcome to MapCache
///   [MapCache][ERROR] Could not download file with error Unknown address
///
/// ```
///
///
public struct Log {
    
    /// The tag [MapCache]
    fileprivate static let tag = "[MapCache]"
    
    /// Log Levels
    fileprivate enum Level : String {
        /// `[Debug]` For displaying messages useful during development.
        case Debug = "[DEBUG]"
        /// `[ERROR]`For displaying messages of bad situations, very, very bad situations.
        case Error = "[ERROR]"
    }
    
    ///
    /// The actual method that prints.
    /// - Parameter level: log level to show
    /// - Parameter message: message to show
    /// - Parameter error: error to show if any on addition to the message. Uses the pattern `{message} with error {error}`
    fileprivate static func log(_ level: Level, _ message: @autoclosure () -> String, _ error: Error? = nil) {
        if let error = error {
            print("\(tag)\(level.rawValue) \(message()) with error \(error)")
        } else {
            print("\(tag)\(level.rawValue) \(message())")
        }
    }
    
    ///
    /// For displaying messages. Useful during development of this package.
    ///
    /// Example:
    /// ```
    /// Log.debug("Hello world") // prints: [MapCache][DEBUG] Hello word
    /// ```
    ///
    /// These messages are displayed only if DEBUG is defined.
    /// - Parameter message: message to display
    /// - Parameter error: error to display if any.
    static func debug(message: @autoclosure () -> String, error: Error? = nil) {
        #if DEBUG
        log(.Debug, message(), error)
        #endif
    }
    
    ///
    /// These messages are displayed independently of the debug mode.
    /// Used  to provide useful information on exceptional situations to library users.
    /// Example:
    /// ```
    /// Log.error("Could not download tile", error) // prints: [MapCache][ERROR] Could not download tile with error No internet connection.
    /// ```
    ///
    /// - Parameter message: message to display
    /// - Parameter error: error to display

    static func error(message: @autoclosure () -> String, error: Error? = nil) {
        log(.Error, message(), error)
    }
    
}
