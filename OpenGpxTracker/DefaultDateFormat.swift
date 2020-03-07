//
//  DefaultDateFormat.swift
//  OpenGpxTracker
//
//  Created by Vincent on 4/3/20.
//

import Foundation

class DefaultDateFormat {
    
    let dateFormatter = DateFormatter()
    
    func getDateFormat(unprocessed: String) -> String {
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
    
    func getDate(processedFormat dateFormat: String, useUTC: Bool = false, useENLocale: Bool = false) -> String {
        //processedDateFormat = DefaultDateFormat.getDateFormat(unprocessed: self.cellTextField.text!)
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = useUTC ? TimeZone(secondsFromGMT: 0) : TimeZone.current
        dateFormatter.locale = useENLocale ? Locale(identifier: "en_US_POSIX") : Locale.current
        return dateFormatter.string(from: Date())
    }

}
