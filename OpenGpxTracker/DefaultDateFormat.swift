//
//  DefaultDateFormat.swift
//  OpenGpxTracker
//
//  Created by Vincent on 4/3/20.
//

import Foundation

class DefaultDateFormat {
    let dateFormatter = DateFormatter()
    
    
    static func getDateFormat(unprocessed: String) -> String {
        var newText = ""
        let arr = unprocessed.components(separatedBy: CharacterSet(charactersIn: "{}"))
        let arrCount = arr.count
        for i in 0...arrCount - 1 {
            if arr.count == 1  {
                newText += "'invalid'"
            }
            else if arrCount > 1 && !arr[i].isEmpty {
                newText += (i % 2 == 0) ? "'\(arr[i])'" : arr[i]//arr[i]
            }
        }

        return newText
    }

}
