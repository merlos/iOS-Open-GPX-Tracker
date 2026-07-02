//
//  MapViewRepresentable.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import SwiftUI
import MapKit
import CoreLocation
import CoreGPX
import Combine

/// A `UIViewRepresentable` that wraps `GPXMapView` for use in SwiftUI.
///
/// This representable creates and configures the `GPXMapView` once, sets up the
/// `MapViewDelegate`, and provides a coordinator that bridges delegate callbacks
/// back to the owning `ContentView` through closures.
struct MapViewRepresentable: UIViewRepresentable {

    // MARK: - Configuration

    /// Reference to the central `AppState`.
    @ObservedObject var appState: AppState

    /// Reference to the `LocationViewModel`.
    @ObservedObject var locationViewModel: LocationViewModel

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MapContainerView {
        let mapView = GPXMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        mapView.showsCompass = false

        // Load saved preferences
        mapView.tileServer = Preferences.shared.tileServer
        mapView.useCache = Preferences.shared.useCache

        // Set up gestures
        mapView.addGestureRecognizer(
            UILongPressGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.addPinAtTappedLocation(_:)))
        )
        let panGesture = UIPanGestureRecognizer(target: context.coordinator,
                                                action: #selector(Coordinator.stopFollowingUser(_:)))
        panGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(panGesture)

        // Set default region
        let center = locationViewModel.locationManager.location?.coordinate
            ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: false)

        // Core Data recovery
        mapView.coreDataHelper.retrieveFromCoreData()

        // Create scale bar and attach to map
        let scaleBar = GPXScaleBar(mapView: mapView, useImperial: Preferences.shared.useImperial)
        scaleBar.forcedColor = forcedColor
        mapView.scaleBar = scaleBar
        appState.scaleBar = scaleBar

        // Store reference in AppState
        appState.mapView = mapView

        // Store reference in coordinator
        context.coordinator.mapView = mapView
        context.coordinator.appState = appState
        context.coordinator.locationViewModel = locationViewModel

        // Subscribe to location updates for track point addition and follow‑user
        context.coordinator.setupSubscriptions(locationViewModel, appState: appState)

        // Create the container view that hosts both map and scale bar
        let container = MapContainerView(mapView: mapView, scaleBar: scaleBar)
        return container
    }
    /// for faking heading in simulator
    private static var simulatedHeading: Double = 0

    func updateUIView(_ container: MapContainerView, context: Context) {
        let mapView = container.mapView
        print("** [updateUIView] called heading: \(locationViewModel.lastHeading)")
        // Update heading indicator arrow whenever a new heading arrives.
        // This is the reliable path: updateUIView is always called because
        // locationViewModel is @ObservedObject and lastHeading is @Published.
        if let heading = locationViewModel.lastHeading {
            let h = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
            //print("[updateUIView] heading trueHeading=\(heading.trueHeading) mag=\(heading.magneticHeading) using=\(h) followMode=\(appState.followUserMode) trackingMode=\(mapView.userTrackingMode.rawValue)")
            mapView.heading = heading
            mapView.updateHeading()
        } else {
            #if targetEnvironment(simulator)
            Self.simulatedHeading += 10
            if Self.simulatedHeading >= 360 { Self.simulatedHeading = 0 }
            let h = Self.simulatedHeading
            print("[updateUIView] heading is nil; courseFallback=\(String(describing: locationViewModel.lastCourse)) followMode=\(appState.followUserMode) trackingMode=\(mapView.userTrackingMode.rawValue) simulated=\(h)")
            if appState.followUserMode == .followWithHeading {
                let center: CLLocationCoordinate2D
                if let last = locationViewModel.lastLocation?.coordinate, CLLocationCoordinate2DIsValid(last) {
                    center = last
                } else if CLLocationCoordinate2DIsValid(mapView.userLocation.coordinate) {
                    center = mapView.userLocation.coordinate
                } else {
                    center = mapView.centerCoordinate
                }
                let camera = MKMapCamera(lookingAtCenter: center,
                                         fromDistance: mapView.camera.altitude,
                                         pitch: mapView.camera.pitch,
                                         heading: h)
                print("[updateUIView] simulated setCamera(heading=\(h))")
                mapView.setCamera(camera, animated: true)
                if mapView.userTrackingMode != .followWithHeading {
                    mapView.setUserTrackingMode(.followWithHeading, animated: true)
                }
            }
            #else
            print("[updateUIView] heading is nil on device — no heading data available")
            #endif
        }

        // Apply MKUserTrackingMode whenever followUserMode changes.
        // updateUIView is called when appState.followUserMode changes because
        // appState is @ObservedObject.
        let desiredMode: MKUserTrackingMode
        switch appState.followUserMode {
        case .none:              desiredMode = .none
        case .follow:            desiredMode = .follow
        case .followWithHeading: desiredMode = .followWithHeading
        }
        if mapView.userTrackingMode != desiredMode {
            print("[updateUIView] followUserMode=\(appState.followUserMode) → setUserTrackingMode(\(desiredMode.rawValue))")
            mapView.setUserTrackingMode(desiredMode, animated: true)
        }

        // Update scale bar visibility and position
        let showScale = Preferences.shared.showScaleBar
        container.scaleBar.isHidden = !showScale
        if showScale {
            // Position scale bar above the tracker button (handled in layoutSubviews)
            container.updateScaleBarPosition()
        }

        // Update forced color for scale bar
        container.scaleBar.forcedColor = forcedColor
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private var forcedColor: UIColor? {
        switch Preferences.shared.tileServer.colorMode {
        case .lightMode: return .black
        case .darkMode: return .white
        case .system:   return nil
        }
    }

    // MARK: - MapContainerView

    /// A plain `UIView` that hosts the `GPXMapView` and the `GPXScaleBar` together.
    class MapContainerView: UIView {
        let mapView: GPXMapView
        let scaleBar: GPXScaleBar

        init(mapView: GPXMapView, scaleBar: GPXScaleBar) {
            self.mapView = mapView
            self.scaleBar = scaleBar
            super.init(frame: .zero)

            mapView.translatesAutoresizingMaskIntoConstraints = false
            scaleBar.translatesAutoresizingMaskIntoConstraints = false
            addSubview(mapView)
            addSubview(scaleBar)

            NSLayoutConstraint.activate([
                mapView.topAnchor.constraint(equalTo: topAnchor),
                mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
                mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
                mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        required init?(coder: NSCoder) { nil }

        func updateScaleBarPosition() {
            let centerX = bounds.midX
            let trackerY = bounds.maxY - 160 // approximate tracker button Y
            scaleBar.center = CGPoint(x: centerX, y: trackerY)
            scaleBar.updateForMapViewChange()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            updateScaleBarPosition()
        }
    }

    // MARK: - Coordinator

    /// Coordinator that acts as the `MKMapViewDelegate` and handles gesture callbacks.
    class Coordinator: MapViewDelegate {
        weak var mapView: GPXMapView?
        var appState: AppState?
        var locationViewModel: LocationViewModel?
        private var locationCancellable: AnyCancellable?
        private var lastAddedLocationTimestamp: Date?
        private var panGestureActive = false

        /// Sets up Combine subscription for track-point recording.
        /// Heading indicator and tracking-mode changes are handled in updateUIView,
        /// which is SwiftUI's guaranteed callback for @ObservedObject changes.
        func setupSubscriptions(_ locationVM: LocationViewModel, appState: AppState) {
            locationCancellable = locationVM.$lastLocation
                .compactMap { $0 }
                .sink { [weak self] location in
                    guard let self = self,
                          let state = self.appState,
                          let mapView = self.mapView else { return }
                    if state.gpxTrackingStatus == .tracking {
                        if self.lastAddedLocationTimestamp == location.timestamp { return }
                        self.lastAddedLocationTimestamp = location.timestamp
                        mapView.addPointToCurrentTrackSegmentAtLocation(location)
                        DispatchQueue.main.async {
                            state.totalDistance = mapView.session.totalTrackedDistance
                            state.currentSegmentDistance = mapView.session.currentSegmentDistance
                        }
                    }
                }
        }

        deinit {
            locationCancellable?.cancel()
        }

        @objc func addPinAtTappedLocation(_ gesture: UILongPressGestureRecognizer) {
            guard gesture.state == .began, let mapView = mapView else { return }
            let point = gesture.location(in: mapView)
            mapView.addWaypointAtViewPoint(point)
            appState?.hasWaypoints = true
        }

        @objc func stopFollowingUser(_ gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                panGestureActive = true
            case .ended, .cancelled:
                panGestureActive = false
                appState?.followUserMode = .none
            default:
                break
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            return true
        }

        /// Sync MKMapView's userTrackingMode changes back to AppState.
        /// Only pan gestures should exit follow mode — pinch/rotate just re-apply.
        override func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            print("[Coordinator] mapView didChangeUserTrackingMode to \(mode.rawValue) animated=\(animated) panGestureActive=\(panGestureActive) appState.follow=\(String(describing: appState?.followUserMode))")
            super.mapView(mapView, didChange: mode, animated: animated)
            // When a non-pan gesture (pinch, rotate) drops tracking mode, re-apply it
            // so the map keeps following the user. Only pan actually exits follow mode.
            if mode == .none, let appState = appState, appState.followUserMode != .none, !panGestureActive {
                let restoreMode: MKUserTrackingMode = appState.followUserMode == .followWithHeading ? .followWithHeading : .follow
                print("[Coordinator] re-applying MKUserTrackingMode.\(restoreMode.rawValue) (pinch/rotate should not exit follow)")
                mapView.setUserTrackingMode(restoreMode, animated: true)
                return
            }
            let newMode: FollowUserMode
            switch mode {
            case .follow:            newMode = .follow
            case .followWithHeading: newMode = .followWithHeading
            case .none:              newMode = .none
            @unknown default:        newMode = .none
            }
            if appState?.followUserMode != newMode {
                appState?.followUserMode = newMode
            }
        }

        override func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                               calloutAccessoryControlTapped control: UIControl) {
            guard let waypoint = view.annotation as? GPXWaypoint,
                  let button = control as? UIButton,
                  let gpxMapView = mapView as? GPXMapView else { return }

            switch button.tag {
            case kDeleteWaypointAccesoryButtonTag:
                gpxMapView.removeWaypoint(waypoint)
            case kEditWaypointAccesoryButtonTag:
                let index = gpxMapView.session.waypoints.firstIndex(of: waypoint)
                let alert = UIAlertController(
                    title: NSLocalizedString("EDIT_WAYPOINT_NAME_TITLE", comment: "no comment"),
                    message: NSLocalizedString("EDIT_WAYPOINT_NAME_MESSAGE", comment: "no comment"),
                    preferredStyle: .alert
                )
                alert.addTextField { tf in
                    tf.text = waypoint.title
                    tf.clearButtonMode = .always
                }
                let save = UIAlertAction(title: NSLocalizedString("SAVE", comment: "no comment"),
                                         style: .default) { _ in
                    waypoint.title = alert.textFields?[0].text
                    if let index = index {
                        gpxMapView.coreDataHelper.update(toCoreData: waypoint, from: index)
                    }
                }
                let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"),
                                           style: .cancel)
                alert.addAction(save)
                alert.addAction(cancel)
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(alert, animated: true)
                }
            default:
                break
            }
        }
    }
}
