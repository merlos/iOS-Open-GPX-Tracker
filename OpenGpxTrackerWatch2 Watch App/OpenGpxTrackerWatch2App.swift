//
//  OpenGpxTrackerWatch2App.swift
//  OpenGpxTrackerWatch2 Watch App
//
//  Created by Vincent Neo on 26/8/26.
//

import SwiftUI

@main
struct GPXTrackerWatchApp: App {
    @State private var navigator = Navigator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigator)
        }
    }
}
