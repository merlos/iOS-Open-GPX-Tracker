//
//  String+CountInstances.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 17/4/20.
//

import Foundation

/// from: https://stackoverflow.com/a/45073012/13292870
/// count occurances
extension String {
    /// counts number of instances of stringToFind; must be of at least 1 character.
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: [.literal], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
    
}
