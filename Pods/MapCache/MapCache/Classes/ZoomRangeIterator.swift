//
//  ZoomRangeIterator.swift
//  MapCache
//
//  Created by merlos on 14/06/2019.
//

import Foundation

/// Iterator that allows the use of ZoomRange in a for loop
///
/// - SeeAlso: https://developer.apple.com/documentation/swift/iteratorprotocol
public struct ZoomRangeIterator: IteratorProtocol {
    
    /// keeps the counter of the iterator
    var  counter : UInt8 = 0
    
    /// the range in question
    var range: ZoomRange
    
    /// receives the range to iterate.
    init(_ range: ZoomRange) {
        self.range = range
    }
    
    /// Gets next zoom value
    mutating public func next() -> Zoom? {
        guard counter < range.count else { return nil }
        let next = range.min + counter
        counter += 1
        return next
    }
}
