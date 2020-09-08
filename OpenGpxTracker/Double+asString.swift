//
//  Double+Time.swift
//  HikeTracker
//
//  Created by Alan Heezen on 7/21/20.
//  Copyright © 2020 Alan Heezen. All rights reserved.
//

import Foundation

extension Double {
  func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second] //, .nanosecond]
    formatter.unitsStyle = style
    guard let formattedString = formatter.string(from: self) else { return "" }
    return formattedString
  }
}
