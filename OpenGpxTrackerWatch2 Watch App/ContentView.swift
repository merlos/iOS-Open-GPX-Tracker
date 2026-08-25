//
//  ContentView.swift
//  OpenGpxTrackerWatch2 Watch App
//
//  Created by Vincent Neo on 26/8/26.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(Navigator.self) private var navigator
    
    // so nothing works now
    // its just trying to mirror the UI for now.
    var body: some View {
        @Bindable var navigator = navigator
        NavigationStack(path: $navigator.path) {
            ScrollView {
                VStack {
                    TrackControlsView()
                    SignalView(hAcc: 50)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
