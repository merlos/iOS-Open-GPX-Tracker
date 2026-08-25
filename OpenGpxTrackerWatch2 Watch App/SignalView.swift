//
//  SignalView.swift
//  OpenGpxTracker
//
//  Created by Vincent Neo on 26/8/26.
//

import SwiftUI
import CoreLocation

struct SignalView: View {
    private let kSignalAccuracy6 = 6.0
    private let kSignalAccuracy5 = 11.0
    private let kSignalAccuracy4 = 31.0
    private let kSignalAccuracy3 = 51.0
    private let kSignalAccuracy2 = 101.0
    private let kSignalAccuracy1 = 201.0
    
    var hAcc: CLLocationAccuracy
    
    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            Image(signalImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 36)
            Text(hAcc.toAccuracy(useImperial: false)) // TODO: read from pref
            Spacer()
        }
    }
    
    private var signalImageName: String {
        let prefix = "signal"
        
        if hAcc < kSignalAccuracy6 {
            return "\(prefix)6"
        } else if hAcc < kSignalAccuracy5 {
            return "\(prefix)5"
        } else if hAcc < kSignalAccuracy4 {
            return "\(prefix)4"
        } else if hAcc < kSignalAccuracy3 {
            return "\(prefix)3"
        } else if hAcc < kSignalAccuracy2 {
            return "\(prefix)2"
        } else if hAcc < kSignalAccuracy1 {
            return "\(prefix)1"
        } else {
            return "\(prefix)0"
        }
    }
}
