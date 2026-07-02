//
//  LocationViewModel.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import Foundation
import CoreLocation

// Global constants `kSignalAccuracy1`–`kSignalAccuracy6`, `kNotGettingLocationText`,
// `kUnknownAccuracyText`, and `kUnknownSpeedText` are defined in ViewController.swift.

/// Observable wrapper around `CLLocationManager` that publishes location,
/// heading, signal strength, speed, and coordinate data for SwiftUI views.
class LocationViewModel: NSObject, ObservableObject {

    // MARK: - Published Properties

    /// The most recent location received from the location manager.
    @Published var lastLocation: CLLocation?

    /// The most recent heading received.
    @Published var lastHeading: CLHeading?

    /// Horizontal accuracy of the last location, in meters.
    @Published var horizontalAccuracy: CLLocationAccuracy = -1

    /// Name of the signal‑strength image asset to display.
    @Published var signalImageName: String = "signal0"

    /// Formatted accuracy string (e.g. "±5m" or "±16ft").
    @Published var accuracyString: String = kUnknownAccuracyText

    /// Formatted coordinate + altitude string.
    @Published var coordsString: String = kNotGettingLocationText

    /// Formatted speed string.
    @Published var speedString: String = kUnknownSpeedText

    /// Whether the app is currently using imperial units (affects formatting).
    var useImperial: Bool {
        didSet { updateAllDisplayValues() }
    }

    // MARK: - Location Manager

    /// The configured `CLLocationManager` instance.
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        manager.activityType = CLActivityType(rawValue: Preferences.shared.locationActivityTypeInt)!
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2
        manager.headingFilter = 3
        manager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        return manager
    }()

    // MARK: - Signal Images

    private let signalImageNames: [String] = [
        "signal0", "signal1", "signal2", "signal3", "signal4", "signal5", "signal6"
    ]

    // MARK: - Init

    override init() {
        useImperial = Preferences.shared.useImperial
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    // MARK: - Public Helpers

    /// Updates the activity type used by the location manager.
    func updateActivityType(_ type: Int) {
        locationManager.activityType = CLActivityType(rawValue: type)!
    }

    /// Starts location updates (called when returning from background).
    func startUpdating() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }

    /// Stops location updates (called when entering background and not tracking).
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Private

    private func updateAllDisplayValues() {
        guard let location = lastLocation else { return }
        updateSignalDisplay(accuracy: location.horizontalAccuracy)
        updateCoordsDisplay(location)
        updateSpeedDisplay(location)
    }

    private func updateSignalDisplay(accuracy: CLLocationAccuracy) {
        accuracyString = accuracy.toAccuracy(useImperial: useImperial)
        switch accuracy {
        case ..<kSignalAccuracy6:  signalImageName = "signal6"
        case ..<kSignalAccuracy5:  signalImageName = "signal5"
        case ..<kSignalAccuracy4:  signalImageName = "signal4"
        case ..<kSignalAccuracy3:  signalImageName = "signal3"
        case ..<kSignalAccuracy2:  signalImageName = "signal2"
        case ..<kSignalAccuracy1:  signalImageName = "signal1"
        default:                   signalImageName = "signal0"
        }
    }

    private func updateCoordsDisplay(_ location: CLLocation) {
        let lat = String(format: "%.6f", location.coordinate.latitude)
        let lon = String(format: "%.6f", location.coordinate.longitude)
        let alt = location.altitude.toAltitude(useImperial: useImperial)
        coordsString = String(format: NSLocalizedString("COORDS_LABEL", comment: "no comment"), lat, lon, alt)
    }

    private func updateSpeedDisplay(_ location: CLLocation) {
        speedString = location.speed < 0
            ? kUnknownSpeedText
            : location.speed.toSpeed(useImperial: useImperial)
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordsString = kNotGettingLocationText
        accuracyString = kUnknownAccuracyText
        signalImageName = "signal0"

        let locationError = error as? CLError
        if locationError?.code == .denied {
            checkLocationServicesStatus()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        lastLocation = newLocation
        horizontalAccuracy = newLocation.horizontalAccuracy

        updateSignalDisplay(accuracy: newLocation.horizontalAccuracy)
        updateCoordsDisplay(newLocation)
        updateSpeedDisplay(newLocation)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        lastHeading = newHeading
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationServicesStatus()
    }

    // MARK: - Authorization Checks

    /// Checks location‑service authorization and shows an alert if denied.
    func checkLocationServicesStatus() {
        let status = locationManager.authorizationStatus
        guard status != .notDetermined else { return }
        guard [.authorizedAlways, .authorizedWhenInUse].contains(status) else {
            NotificationCenter.default.post(name: .showLocationDeniedAlert, object: nil)
            return
        }
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    /// Posted when the user should be alerted that location access was denied.
    static let showLocationDeniedAlert = Notification.Name("showLocationDeniedAlert")
}
