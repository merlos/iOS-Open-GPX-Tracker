//
//  Date+timeAgo.swift
//  OpenGpxTracker
//
//  Created by merlos on 23/09/2018.
//
//  Localized by nitricware on 19/08/19.
//
// Based on this discussion: https://gist.github.com/minorbug/468790060810e0d29545

// If future dates are needed at some point. This other implementation may help:
//    https://gist.github.com/jinthagerman/009c85b7bbd0a40dcbba747e89a501bf
//
import Foundation

extension Date {
    
    ///
    /// Provides a humanified date. For instance: 1 minute, 1 week ago, 3 months ago
    ///
    /// - Parameters:
    ///      - numericDates: Set it to true to get "1 year ago", "1 month ago" or false if you prefer "Last year", "Last month"
    ///
    func timeAgo(numericDates: Bool) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = self < now ? self : now
        let latest =  self > now ? self : now
        
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfMonth, .month, .year, .second]
        let components: DateComponents = calendar.dateComponents(unitFlags, from: earliest, to: latest)
        if let year = components.year {
            if year >= 2 {
                return String(format: NSLocalizedString("T_YEARS_AGO", comment: ""), year)
            } else if year >= 1 {
                return numericDates ? NSLocalizedString("T_YEAR_AGO", comment: "") : NSLocalizedString("T_LAST_YEAR", comment: "")
            }
        }
        if let month = components.month {
            if month >= 2 {
                return String(format: NSLocalizedString("T_MONTHS_AGO", comment: ""), month)
            } else if month >= 1 {
                let monthAgo = NSLocalizedString("T_MONTH_AGO", comment: "")
                let lastMonth = NSLocalizedString("T_LAST_MONTH", comment: "")
                return numericDates ? monthAgo : lastMonth
            }
        }
        if let weekOfMonth = components.weekOfMonth {
            if weekOfMonth >= 2 {
                return String(format: NSLocalizedString("T_WEEKS_AGO", comment: ""), weekOfMonth)
            } else if weekOfMonth >= 1 {
                return numericDates ? NSLocalizedString("T_WEEK_AGO", comment: "") : NSLocalizedString("T_LAST_WEEK", comment: "")
            }
        }
        if let day = components.day {
            if day >= 2 {
                return String(format: NSLocalizedString("T_DAYS_AGO", comment: ""), day)
            } else if day >= 1 {
                return numericDates ? NSLocalizedString("T_DAY_AGO", comment: "") : NSLocalizedString("T_YESTERDAY", comment: "")
            }
        }
        if let hour = components.hour {
            if hour >= 2 {
                return String(format: NSLocalizedString("T_HOURS_AGO", comment: ""), hour)
            } else if hour >= 1 {
                return numericDates ? NSLocalizedString("T_HOUR_AGO", comment: "") : NSLocalizedString("T_LAST_HOUR", comment: "")
            }
        }
        if let minute = components.minute {
            if minute >= 2 {
                return String(format: NSLocalizedString("T_MINUTES_AGO", comment: ""), minute)
            } else if minute >= 1 {
                return numericDates ? NSLocalizedString("T_MINUTE_AGO", comment: "") : NSLocalizedString("T_LAST_MINUTE", comment: "")
            }
        }
        if let second = components.second {
            if second >= 3 {
                return String(format: NSLocalizedString("T_SECONDS_AGO", comment: ""), second)
            }
        }
        return NSLocalizedString("T_JUST_NOW", comment: "")
    }
}
