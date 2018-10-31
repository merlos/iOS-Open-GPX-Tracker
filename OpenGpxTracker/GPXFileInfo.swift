//
//  GPXFileInfo.swift
//  OpenGpxTracker
//
//  Created by merlos on 23/09/2018.
//

import Foundation
import MapKit

///
/// A handy way of getting info of a GPX file.
///
/// It gets info like filename, modified date, filesize
///
///
class GPXFileInfo: NSObject {
    
    /// file URL
    var fileURL: URL = URL(fileURLWithPath: "")
    
    /// last time the file was modified
    var modifiedDate: Date {
        get {
            return try! fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? Date.distantPast
        }
    }
    
    //
    var modifiedDatetimeAgo: String {
        get {
            return modifiedDate.timeAgo(numericDates: true)
        }
    }
    /// file size in bytes
    var fileSize: Int {
        get {
            return try! fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        }
    }
    
    ///
    var fileSizeHumanised: String {
        get {
            return fileSize.asFileSize()
        }
    }
    
    /// distance from file log
    var fileDistance: CLLocationDistance {
        get {
            let gpx = GPXParser.parseGPX(atPath: fileURL.path)
            return (gpx?.tracksLength)!
        }
    }
    
    var fileTimeElapsed: String {
        get {
            let gpx = GPXParser.parseGPX(atPath: fileURL.path)
            let track = gpx?.tracks as! [GPXTrack] // tracks of gpx file
            let trackSegments = track.first?.tracksegments as! [GPXTrackSegment] // first track segment of tracks
            let startDate = trackSegments.first?.trackpoints.first as! GPXTrackPoint
            let lastDate = trackSegments.last?.trackpoints.last as! GPXTrackPoint
            
            let timeElapsed = Int(lastDate.time.timeIntervalSince(startDate.time))
            
            let seconds = timeElapsed % 60
            let minutes = (timeElapsed / 60) % 60
            let hours = (timeElapsed / 3600)
            
            if hours == 0 && minutes > 0 {
                return String(format: "%0.2dmins %0.2ds",minutes,seconds)
            }
            else if minutes == 0 && seconds > 0 {
                return String(format: "%0.2ds",seconds)
            }
            else {
                 return String(format: "%0.2dhrs %0.2dmins %0.2ds",hours,minutes,seconds)
            }

        }
    }
    
    /// Reverse Geocode data, provides basic location from the first tracksegment
    func geocode(completion: @escaping (_ results: String?, _ error: Error?) -> ()) {
        let gpx = GPXParser.parseGPX(atPath: fileURL.path) // path of file
        let track = gpx?.tracks as! [GPXTrack] // tracks of gpx file
        let trackSegments = track.first?.tracksegments as! [GPXTrackSegment] // first track segment of tracks
        let tr = trackSegments.first?.trackpoints.first as! GPXTrackPoint
        let t3 = tr.time
        let coordinates = trackSegments.first?.trackPointsToCoordinates().first
        let coder = CLGeocoder()
        
        if coordinates != nil { // in case of handling empty/corrupt gpx files
            let location = CLLocation(latitude: (coordinates?.latitude)!, longitude: (coordinates?.longitude)!)
            coder.reverseGeocodeLocation(location) { (placemarks,error) in
                
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                let geocodeResult = placeMark.thoroughfare! + ", " + placeMark.country!
                completion(geocodeResult, error)

            }
        }
        else {
            completion("Location Not Found", nil)
        }
        
    }
    
    /// The filename without extension
    var fileName: String {
        get {
            return fileURL.deletingPathExtension().lastPathComponent
        }
    }
    
    ///
    /// Initializes the object with the URL of the file to get info.
    ///
    /// - Parameters:
    ///     - fileURL: the URL of the GPX file.
    ///
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }
    
}
