//
//  Track.swift
//  Location Tester
//
//  Created by Alan Heezen on 4/20/20.
//  Copyright © 2020 Alan Heezen. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion

class Track  //: Codable
{
    var points: [CLLocation] = [] // trackpoints
    var startingDate: Date?    // right now - at instantiation
    var grossErrorBound: CLLocationDistance
    var spacingFactor: Double
    var trackLength: CLLocationDistance
    var saveNextPoint: Bool

    let dateFormatter = ISO8601DateFormatter()
    var nameString: String = "Test Track"

    init(withSpacingFactor factor: Double, withGrossErrorBound error: CLLocationDistance) {
        self.spacingFactor = factor
        grossErrorBound = error
        trackLength = 0.0
        dateFormatter.timeZone = TimeZone.current
        
        // default file name is the ISO8601 timestamp truncated after the local time and with the colon removed
        // e.g. 2020-05-27T16:01:56-07:00 ---> 2020-05-27T1601
        nameString = String(dateFormatter.string(from: Date()).prefix(16)) // now
        let zapColon = nameString.lastIndex(of: ":")
        if zapColon != nil {
            nameString.remove(at: zapColon!)
        }
        saveNextPoint = false
        // debug
    }
    
    func add(_ newPoint: CLLocation) -> Bool {
        var newSpacing = 0.0
        let newAccuracy = newPoint.accuracy()
        
        if points.count <= 0 {
//            print(" first = ", newPoint.altitude as Double)
            if (newAccuracy <= grossErrorBound) {
                // ??? Start the motion detector at this point
                points.append(newPoint)
                trackLength = 0.0
                saveNextPoint = false
                startingDate = Date()
                return true
            } else {
                return false
            }
        }
//        print("last = ", points.last!.altitude as Double)
//        show(n:58, point:points.last!, message:"Track.add: points.last!")
//        show(n:59, point:newPoint, message:"Track.add: newPoint")
//
//        print(" new = ", newPoint.altitude as Double)
        newSpacing = newPoint.distance(from: points.last!)
        if newSpacing > 0 {
            points.append(newPoint)
            trackLength += newSpacing
            saveNextPoint = false
            return true
        }
        return false
    }
    
    func toGPX(withMessage message: String?) -> Data {

        var result = Data()
        let xmlCode = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        let gpxCode = "<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" version=\"1.1\" xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\" creator=\"http://www.geezerhiker.com\">"
        let nameCode = "<name>" + nameString + "</name>"
        
        if message != nil { result.append(toData(message!)) }
    
        result.append(toData(xmlCode))
        result.append(toData(gpxCode))
        result.append(toData("<metadata>"))
        result.append(toData(nameCode))
        result.append(toData("</metadata>"))
        result.append(toData("<trk>"))
        result.append(toData(nameCode))
        result.append(toData("<trkseg>"))
        
        for trkPt in points {
            result.append(toData(trkPt))
        }
        
        result.append(toData("</trkseg>"))
        result.append(toData("</trk>"))
        result.append(toData("</gpx>"))

        return result
    }
    // helpers for toGPX
    func toData(_ string: String) -> Data {
//        print(string)
        return (string+"\n").data(using: String.Encoding.utf8)!
    }
    func toData(_ trackPoint: CLLocation) -> Data {
        let lon = String(format: "lon=\"%.7f\" ", trackPoint.coordinate.longitude)
        let lat = String(format: "lat=\"%.7f\"", trackPoint.coordinate.latitude)
        let ele = String(format: "\t<ele>%.2f</ele>\n", trackPoint.altitude)  // round elevation to 2 places
        let time = String(format: "\t<time>" +  dateFormatter.string(from: trackPoint.timestamp) + "</time>\n" )
        let result = "<trkpt " + lon + lat + ">\n" + ele + time + "</trkpt>"
        
//        print(result)
        return (result+"\n").data(using: String.Encoding.utf8)!
    }
    // save as tab-separated values
    func toCSV() -> Data {
        var result = Data()
        let nameCode = "<name>" + nameString + "</name>"
        
        result.append(toData("\tlat\tlon\talt\thacc\tvacc\ttime"))
        for trkpt in points {
            result.append(toCSVData(trkpt))
        }
        result.append(toData(nameCode))
        return result
    }
    func toCSVData(_ trackPoint: CLLocation) -> Data {
        var csv = String(format: "\t%.7f\t", trackPoint.coordinate.latitude)
        csv += String(format: "%.7f\t", trackPoint.coordinate.longitude)
        csv += String(format: "%.7f\t", trackPoint.altitude)
        csv += String(format: "%.7f\t", trackPoint.horizontalAccuracy)
        csv += String(format: "%.7f\t", trackPoint.verticalAccuracy)
        csv += String(format: "%.0f\n", trackPoint.timestamp.timeIntervalSince1970)
        return csv.data(using: String.Encoding.utf8)!
    }
    

    // Setters & Getters
    
    func length() -> CLLocationDistance {
        return trackLength
    }
    func count() -> Int {
        return points.count
    }
    func setName(_ newName: String) -> Void {
        nameString = newName
    }
    func getName() -> String {
        return nameString
    }
    func setSpacingFactor(to factor: Double) {
        spacingFactor = factor
    }
    func saveOnePoint() {
        saveNextPoint = true
    }
    func elapsedTimeString() -> String {
        if startingDate == nil {
            return ""
        } else {
            return Date().timeIntervalSince(startingDate!).asString(style: DateComponentsFormatter.UnitsStyle.positional)
        }
    }
}
 
