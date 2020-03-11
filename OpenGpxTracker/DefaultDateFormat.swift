//
//  DefaultDateFormat.swift
//  OpenGpxTracker
//
//  Created by Vincent on 4/3/20.
//

import Foundation

/// Handles processing of 'unprocessed' user input date format, processing of sample date format, etc
class DefaultDateFormat {
    
    /// DateFormatter for use in each instance.
    let dateFormatter = DateFormatter()
    
    /// returns a 'processed', `DateFormatter`-friendly date format.
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
    
    /// Returns sample date time based on user input.
    func getDate(processedFormat dateFormat: String, useUTC: Bool = false, useENLocale: Bool = false) -> String {
        //processedDateFormat = DefaultDateFormat.getDateFormat(unprocessed: self.cellTextField.text!)
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = useUTC ? TimeZone(secondsFromGMT: 0) : TimeZone.current
        dateFormatter.locale = useENLocale ? Locale(identifier: "en_US_POSIX") : Locale.current
        return dateFormatter.string(from: Date())
    }
    
    /// Returns Preference stored date format and its settings.
    func getDateFromPrefs() -> String {
        let dateFormat = Preferences.shared.dateFormat
        let useUTC = Preferences.shared.dateFormatUseUTC
        let useEN = Preferences.shared.dateFormatUseEN
        return getDate(processedFormat: dateFormat, useUTC: useUTC, useENLocale: useEN)
        
    }

}
