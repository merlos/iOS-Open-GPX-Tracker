//
//  Int+inKB.swift
//  OpenGpxTracker
//
//  Created by merlos on 23/09/2018.
//  Copyright © 2018 TransitBox. All rights reserved.
//

import Foundation

/// Extension to display humanized filesizes
extension Int {
    
    /// Returns the integer as file size humanized (for instance: 1024 -> "1 KB" )
    func asFileSize() -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(self))
        //print("formatted result: \(string)")
        return string
    }
}
