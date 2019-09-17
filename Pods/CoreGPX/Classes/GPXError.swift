//
//  GPXError.swift
//  Pods
//
//  Created by Vincent on 4/9/19.
//

import Foundation

/// Throwable errors for GPX library
public struct GPXError {
    
    /// Coordinates related errors
    public enum coordinates: Error {
        /// when lat is outside range (-90˚ to 90˚)
        case invalidLatitude(dueTo: reason)
        /// when lon is outside range (-180˚ to 180˚)
        case invalidLongitude(dueTo: reason)
        
        /// reason of why a coordinate error is thrown.
        public enum reason {
            /// < -90˚ (lat) / < -180˚ (lon)
            case underLimit
            /// > 90˚ (lat) / > 180˚ (lon)
            case overLimit
        }
    }
    
    /// Parser related errors
    public enum parser: Error {
        /// Thrown when GPX version is < 1.1
        case unsupportedVersion
        /// When an issue occurred at line, but without further comment.
        case issueAt(line: Int)
        /// Thrown when issue occurred at line. (Mostly wraps XML parser errors)
        case issueAt(line: Int, error: Error)
        /// Thrown when file is XML, but not GPX.
        case fileIsNotGPX
        /// Thrown when file is not XML, let alone GPX.
        case fileIsNotXMLBased
        /// Thrown when file does not conform schema. (unused)
        case fileDoesNotConformSchema
        /// Thrown when file is presumed to be empty.
        case fileIsEmpty
        /// When multiple errors occurred, to give an array of errors.
        case multipleErrorsOccurred(_ errors: [Error])
    }
    
    /// Checks if latitude and longitude is valid (within range)
    static func checkError(latitude: Double, longitude: Double) -> Error? {
        guard latitude >= -90 && latitude <= 90 else {
            if latitude <= -90 {
                return GPXError.coordinates.invalidLatitude(dueTo: .underLimit)
            }
            else {
                return GPXError.coordinates.invalidLatitude(dueTo: .overLimit)
            }
        }
        guard longitude >= -180 && longitude <= 180 else {
            if longitude <= -180 {
                return GPXError.coordinates.invalidLongitude(dueTo: .underLimit)
            }
            else {
                return GPXError.coordinates.invalidLongitude(dueTo: .overLimit)
            }
        }
        
        return nil
    }
}
