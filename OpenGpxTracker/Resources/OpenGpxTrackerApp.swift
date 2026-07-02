//
//  OpenGpxTrackerApp.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import SwiftUI

/// The main entry point for the Open GPX Tracker application, now powered by
/// SwiftUI.  The `UIApplicationDelegateAdaptor` keeps the existing `AppDelegate`
/// alive for URL handling and Watch Connectivity (`WCSessionDelegate`).
@main
struct OpenGpxTrackerApp: App {

    /// The legacy app delegate that handles `WCSession` and URL‑based file imports.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// Shared toast presenter for the whole app.
    @StateObject private var toastPresenter = ToastPresenter()

    /// Central app state object.
    @StateObject private var appState = AppState()

    /// Location services view model.
    @StateObject private var locationViewModel = LocationViewModel()

    /// Whether the preferences sheet is presented.
    @State private var showPreferences = false

    /// Whether the GPX files sheet is presented.
    @State private var showGPXFiles = false

    /// Whether the location‑access alert is presented.
    @State private var showLocationAlert = false

    var body: some Scene {
        WindowGroup {
            ContentView(
                appState: appState,
                locationViewModel: locationViewModel,
                toastPresenter: toastPresenter,
                showPreferences: $showPreferences,
                showGPXFiles: $showGPXFiles
            )
            .overlay(ToastOverlay(presenter: toastPresenter))
            .sheet(isPresented: $showPreferences) {
                NavigationView {
                    PreferencesView(appState: appState, locationViewModel: locationViewModel)
                }
            }
            .sheet(isPresented: $showGPXFiles) {
                NavigationView {
                    GPXFilesView(appState: appState)
                }
            }
            .alert(isPresented: $showLocationAlert) {
                Alert(
                    title: Text(NSLocalizedString("ACCESS_TO_LOCATION_DENIED", comment: "no comment")),
                    message: Text(NSLocalizedString("ALLOW_LOCATION", comment: "no comment")),
                    primaryButton: .default(Text(NSLocalizedString("SETTINGS", comment: "no comment"))) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel(Text(NSLocalizedString("CANCEL", comment: "no comment")))
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .showLocationDeniedAlert)) { _ in
                showLocationAlert = true
            }
            .environmentObject(appState)
            .environmentObject(locationViewModel)
            .environmentObject(toastPresenter)
        }
    }
}
