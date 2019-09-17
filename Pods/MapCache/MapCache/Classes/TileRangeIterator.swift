//
//  TileRangeOperator.swift
//  MapCache
//
//  Created by merlos on 13/06/2019.
//

import Foundation

//
public struct TileRangeIterator: IteratorProtocol {
    
    /// Range for the counter
    let range: TileRange
    
    /// Counter
    var counter: UInt64
    
    /// Max value counter can take.
    let maxCounter : UInt64
    
    /// Number of columns
    let columns : TileNumber
    
    /// Number of rows
    let rows : TileNumber
    /// initializer of the iterator.
    /// Sets range, counter, maxCounter and diffX
    init(_ range: TileRange) {
        self.range = range
        counter = 0
        
        // we keep these in memory for efficiency
        // so they do not need to be calculated again
        maxCounter = range.count
        columns = range.columns
        rows = range.rows
    }
    
    /// The function that is required by the Iterator protocol.
    /// - Returns: the TileCoord for the current iteration.
    ///
    /// - TODO: because there are no validations of the range in TileRange,
    ///          this function may fail. Pending to fix it.
    ///
    /// See: https://developer.apple.com/documentation/swift/iteratorprotocol
    mutating public func next() -> TileCoords? {
        guard counter < maxCounter else { return nil }
        let currentColumn = counter % columns
        let currentRow = Double(counter / columns)
        
        let x = range.minTileX + currentColumn //We start in the topLeft corner
        let y = range.maxTileY - UInt64(currentRow.rounded(.down))   // point and end in the bottomRight corner
        counter += 1
        guard let nextTileCoords = TileCoords(tileX: x, tileY: y, zoom: range.zoom)
            else {
                return nil
        }
        return nextTileCoords
    }
}
