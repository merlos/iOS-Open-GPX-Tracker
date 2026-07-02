//
//  AppState.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import Foundation
import CoreLocation
import CoreGPX
import MapKit

/// Possible statuses regarding tracking current user location.
enum GpxTrackingStatus {
    /// Tracking has not started or map was reset
    case notStarted
    /// Tracking is ongoing
    case tracking
    /// Tracking is paused (the map has some contents)
    case paused
}

/// Central observable state object for the application.
///
/// `AppState` holds all shared state that drives the SwiftUI interface:
/// tracking status, UI label values, follow‑user mode, filename, and the
/// `StopWatch` instance.  It also acts as the delegate of `StopWatch` and
/// provides callback methods for preference changes and GPX file loading.
///
/// The `mapView` property is set after the `GPXMapView` is created inside the
/// `UIViewRepresentable`, so it is weak to avoid ownership cycles.
class AppState: ObservableObject {

    // MARK: - Tracking State

    /// Current tracking status (notStarted / tracking / paused).
    @Published var gpxTrackingStatus: GpxTrackingStatus = .notStarted {
        didSet {
            switch gpxTrackingStatus {
            case .notStarted:
                stopWatch.reset()
                timeString = stopWatch.elapsedTimeString
                mapView?.clearMap()
                lastGpxFilename = ""
                hasWaypoints = false
                mapView?.coreDataHelper.clearAll()
                mapView?.coreDataHelper.coreDataDeleteAll(of: CDRoot.self)
                totalDistance = 0
                currentSegmentDistance = 0
            case .tracking:
                stopWatch.start()
            case .paused:
                stopWatch.stop()
                mapView?.startNewTrackSegment()
            }
        }
    }

    /// When true the map is automatically centered on the user location.
    @Published var followUser: Bool = true

    /// Name of the last GPX file saved (without extension).
    @Published var lastGpxFilename: String = "" {
        didSet {
            appTitleString = lastGpxFilename.isEmpty
                ? "  Open GPX Tracker"
                : "  \(lastGpxFilename.truncated(limit: 20)).gpx"
        }
    }

    /// Whether the map currently contains any waypoints.
    @Published var hasWaypoints: Bool = false

    // MARK: - UI Labels

    /// Elapsed time string (e.g. "03:30").
    @Published var timeString: String = "00:00"

    /// Speed string (e.g. "5.2 km/h").
    @Published var speedString: String = "·.··"

    /// Total tracked distance in meters.
    @Published var totalDistance: CLLocationDistance = 0

    /// Current segment distance in meters.
    @Published var currentSegmentDistance: CLLocationDistance = 0

    /// Coordinate / altitude string (e.g. "40.4168, -3.7038, 650m").
    @Published var coordsString: String = NSLocalizedString("NO_LOCATION", comment: "no comment")

    /// Name of the signal image asset to display.
    @Published var signalImageName: String = "signal0"

    /// Accuracy text (e.g. "±5m").
    @Published var signalAccuracyString: String = "±···"

    /// Title displayed in the top‑left corner.
    @Published var appTitleString: String = "  Open GPX Tracker"

    // MARK: - StopWatch

    /// The stopwatch that provides elapsed‑time updates.
    let stopWatch = StopWatch()

    // MARK: - Map View Reference

    /// Weak reference to the `GPXMapView` so the representable can set it
    /// after creation without creating a strong reference cycle.
    weak var mapView: GPXMapView? {
        didSet {
            mapView?.delegate = mapViewDelegate
            isMapReady = mapView != nil
        }
    }

    /// Whether the map view has been created and assigned.
    @Published var isMapReady = false

    /// Optional reference to the scale bar (owned by the map container view).
    weak var scaleBar: GPXScaleBar?

    /// The shared `MapViewDelegate` instance serving `MKMapViewDelegate`.
    let mapViewDelegate = MapViewDelegate()

    // MARK: - Initialization

    init() {
        stopWatch.delegate = self
    }

    // MARK: - Actions

    /// Toggles the tracking state machine.
    func trackerButtonTapped() {
        switch gpxTrackingStatus {
        case .notStarted: gpxTrackingStatus = .tracking
        case .tracking:   gpxTrackingStatus = .paused
        case .paused:     gpxTrackingStatus = .tracking
        }
    }

    /// Toggles follow‑user mode.
    func toggleFollowUser() {
        followUser.toggle()
    }

    /// Generates the default filename based on user preferences.
    func defaultFilename() -> String {
        let defaultDate = DefaultDateFormat()
        return defaultDate.getDateFromPrefs()
    }

    /// Initiates the share flow by exporting to a temporary GPX file.
    func shareGPX() -> URL? {
        guard let mapView = mapView else { return nil }
        let filename = lastGpxFilename.isEmpty ? defaultFilename() : lastGpxFilename
        let gpxString = mapView.exportToGPXString()
        let tmpFile = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(filename).gpx")
        GPXFileManager.saveToURL(tmpFile, gpxContents: gpxString)
        return tmpFile
    }

    /// Handles recovered crash data from Core Data.
    func handleCrashRecovery(_ notification: Notification) {
        guard let root = notification.userInfo?["recoveredRoot"] as? GPXRoot,
              let fileName = notification.userInfo?["fileName"] as? String else { return }

        lastGpxFilename = fileName
        mapView?.coreDataHelper.add(toCoreData: fileName, willContinueAfterSave: false)
        stopWatch.reset()
        mapView?.continueFromGPXRoot(root)
        followUser = false
        mapView?.regionToGPXExtent()
        gpxTrackingStatus = .paused
        if let mapView = mapView {
            totalDistance = mapView.session.totalTrackedDistance
        }
    }

    /// Saves the current session as a GPX file with the given name.
    func saveSession(withName name: String, resetAfterSave: Bool = false) {
        guard let mapView = mapView else { return }
        let gpxString = mapView.exportToGPXString()
        GPXFileManager.save(name, gpxContents: gpxString)
        lastGpxFilename = name
        mapView.coreDataHelper.coreDataDeleteAll(of: CDRoot.self)
        mapView.coreDataHelper.clearAllExceptWaypoints()
        mapView.coreDataHelper.add(toCoreData: name, willContinueAfterSave: true)
        if resetAfterSave {
            gpxTrackingStatus = .notStarted
        }
    }
}

// MARK: - StopWatchDelegate

extension AppState: StopWatchDelegate {
    func stopWatch(_ stropWatch: StopWatch, didUpdateElapsedTimeString elapsedTimeString: String) {
        DispatchQueue.main.async {
            self.timeString = elapsedTimeString
        }
    }
}

// MARK: - String Helper

private extension String {
    func truncated(limit: Int) -> String {
        guard count > limit else { return self }
        return "\(prefix(10))...\(suffix(3))"
    }
}
