//
//  GPXCopyright.swift
//  GPXKit
//
//  Created by Vincent on 22/11/18.
//

import Foundation

open class GPXCopyright: GPXElement {
    
    public var year: Date?
    public var license: String?
    public var author: String?
    
    // MARK:- Instance
    
    public required init() {
        super.init()
    }
    
    public init(author: String) {
        super.init()
        self.author = author
    }
    
    init(dictionary: [String : String]) {
        super.init()
        self.year = CopyrightYearParser.parse(dictionary["year"])
        self.license = dictionary["license"]
        self.author = dictionary["author"]
    }
    
    // MARK: Tag
    
    override func tagName() -> String {
        return "copyright"
    }
    
    // MARK: GPX
    
    override func addOpenTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        let attribute = NSMutableString()
        
        if let author = author {
            attribute.appendFormat(" author=\"%@\"", author)
        }
        
        gpx.appendFormat("%@<%@%@>\r\n", tagName())
    }
    
    override func addChildTag(toGPX gpx: NSMutableString, indentationLevel: Int) {
        super.addChildTag(toGPX: gpx, indentationLevel: indentationLevel)
        self.addProperty(forValue: GPXType().value(forDateTime: year), gpx: gpx, tagName: "year", indentationLevel: indentationLevel)
        self.addProperty(forValue: license, gpx: gpx, tagName: "license", indentationLevel: indentationLevel)
    }
}

// MARK:- Year Parser
// code from http://jordansmith.io/performant-date-parsing/
// edited for use in CoreGPX

fileprivate class CopyrightYearParser {
    
    private static var calendarCache = [Int : Calendar]()
    private static var components = DateComponents()
    
    private static let year = UnsafeMutablePointer<Int>.allocate(capacity: 1)
    
    static func parse(_ yearString: String?) -> Date? {
        guard let NonNilString = yearString else {
            return nil
        }
        
        _ = withVaList([year], { pointer in
                            vsscanf(NonNilString, "%d", pointer)
                            
        })
        
        components.year = year.pointee
        
        if let calendar = calendarCache[0] {
            return calendar.date(from: components)
        }
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        calendarCache[0] = calendar
        return calendar.date(from: components)
    }
}
