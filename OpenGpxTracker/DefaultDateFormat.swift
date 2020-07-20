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
    func getDateFormat(unprocessed: String) -> (String, Bool) {
        var newText = ""
        var isInvalid = false
        // prevents acknowledging unterminated date formats as valid
        if (unprocessed.countInstances(of: "{") != unprocessed.countInstances(of: "}"))
        || unprocessed.countInstances(of: "{}") > 0 {
            newText = "'invalid'"
            isInvalid = true
        } else {
            let arr = unprocessed.components(separatedBy: CharacterSet(charactersIn: "{}"))
            var lastField: String?
            let arrCount = arr.count
            for i in 0...arrCount - 1 {
                if let lastField = lastField, lastField.countInstances(of: String(arr[i].last ?? Character(" "))) > 0 {
                    newText = "'invalid: { ... } must not consecutively repeat'"
                    isInvalid = true
                    break
                }
                if arr.count == 1 {
                    newText += "'invalid'"
                    isInvalid = true
                } else if arrCount > 1 && !arr[i].isEmpty {
                    newText += (i % 2 == 0) ? "'\(arr[i])'" : arr[i]
                    lastField = (i % 2 != 0) ? arr[i] : nil
                }
            }
        }
        return (newText, isInvalid)
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
