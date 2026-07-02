//
//  ContentView.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import SwiftUI
import MapKit
import CoreGPX

/// The root SwiftUI view that replaces the UIKit `ViewController`.
///
/// `ContentView` composes the map, the overlay info panel, the control bar,
/// and the top‑left action buttons (folder, preferences, share, about).
struct ContentView: View {

    // MARK: - Properties

    /// Central app state.
    @ObservedObject var appState: AppState

    /// Location services view model.
    @ObservedObject var locationViewModel: LocationViewModel

    /// Toast presenter for transient notifications.
    @ObservedObject var toastPresenter: ToastPresenter

    /// Whether the preferences sheet should be shown.
    @Binding var showPreferences: Bool

    /// Whether the GPX files sheet should be shown.
    @Binding var showGPXFiles: Bool

    /// Whether the reset action sheet is presented.
    @State private var showResetAction = false

    /// Whether the save alert is presented (text field alert).
    @State private var showSaveAlert = false

    /// The filename entered in the save alert.
    @State private var saveFileName = ""

    /// Whether to reset after saving (when "Save & Start New" is chosen).
    @State private var resetAfterSave = false

    /// Whether the share sheet is presented.
    @State private var showShareSheet = false

    /// The temporary file URL to share.
    @State private var shareURL: URL?

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Map fills the entire screen (includes scale bar as subview)
                MapViewRepresentable(
                    appState: appState,
                    locationViewModel: locationViewModel
                )
                .ignoresSafeArea()

                // Top bar: title, signal, coords — sits below the notch naturally
                topBar
                    .padding(.top, 8)

                // Left action buttons
                leftActionButtons(in: geometry)

                // Info labels (right side)
                infoLabelStack(in: geometry)

                // Allow touches to pass through to the map except where controls are
                Color.clear
                    .contentShape(Rectangle())
                    .allowsHitTesting(false)

                // Bottom control bar
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ControlBarView(
                            appState: appState,
                            onAddPin: { addPinAtMyLocation() },
                            onSave: { presentSaveAlert() },
                            onReset: { presentResetAction() }
                        )
                        Spacer()
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 15)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            locationViewModel.startUpdating()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            if appState.gpxTrackingStatus != .tracking {
                locationViewModel.stopUpdating()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadRecoveredFile)) { notification in
            appState.handleCrashRecovery(notification)
            if let fileName = notification.userInfo?["fileName"] as? String {
                let msg = NSLocalizedString("LAST_SESSION_LOADED", comment: "") + " \n" + fileName + ".gpx"
                toastPresenter.success(msg)
            }
        }
        // Reset action sheet
        .confirmationDialog(NSLocalizedString("SELECT_OPTION", comment: "no comment"),
                            isPresented: $showResetAction,
                            titleVisibility: .visible) {
            Button(NSLocalizedString("SAVE_START_NEW", comment: "no comment")) {
                resetAfterSave = true
                presentSaveAlert()
            }
            Button(NSLocalizedString("RESET", comment: "no comment"), role: .destructive) {
                appState.gpxTrackingStatus = .notStarted
                GPXFileManager.removeTemporaryFiles()
            }
            Button(NSLocalizedString("CANCEL", comment: "no comment"), role: .cancel) {}
        }
        // Share sheet
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
        // Compass button overlay (native MKCompassButton via representable)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 4) {
            // Grey bar with title + coords
            HStack(alignment: .center, spacing: 4) {
                Text(appState.appTitleString)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)

                Spacer()

                Text(locationViewModel.coordsString)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 3)
            .background(Color(red: 58/255, green: 57/255, blue: 54/255).opacity(0.8))
            .cornerRadius(4)

            // Signal + accuracy underneath the bar
            HStack(spacing: 4) {
                Image(locationViewModel.signalImageName)
                    .resizable()
                    .frame(width: 50, height: 30)
                Text(locationViewModel.accuracyString)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(textColor)
            }

            // Compass button underneath the signal
            if appState.isMapReady {
                CompassButtonView(mapView: appState.mapView)
                    .frame(width: 36, height: 36)
            }
        }
    }

    // MARK: - Left Action Buttons

    private func leftActionButtons(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 5) {
            Button(action: { showGPXFiles = true }) {
                Image(systemName: "folder")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }

            HStack(spacing: 10) {
                Button(action: { showPreferences = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                Button(action: { shareGPX() }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 40, height: 40)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.leading, 5)
        .padding(.top, 49)
    }

    // MARK: - Info Label Stack (right side)

    private func infoLabelStack(in geometry: GeometryProxy) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            Spacer().frame(height: 64)

            Text(appState.timeString)
                .font(.custom("DinCondensed-Bold", size: 36))
                .foregroundColor(textColor)

            Text(locationViewModel.speedString)
                .font(.custom("DinAlternate-Bold", size: 18))
                .foregroundColor(textColor)

            Text(totalTrackedDistanceString)
                .font(.custom("DinCondensed-Bold", size: 36))
                .foregroundColor(textColor)

            Text(currentSegmentDistanceString)
                .font(.custom("DinAlternate-Bold", size: 18))
                .foregroundColor(textColor)

            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 7)
        .padding(.leading, geometry.size.width / 2 + 25)
    }

    // MARK: - Helpers

    private var textColor: Color {
        switch Preferences.shared.tileServer.colorMode {
        case .lightMode: return .black
        case .darkMode: return .white
        case .system:   return .primary
        }
    }

    private var totalTrackedDistanceString: String {
        appState.totalDistance.toDistance(useImperial: Preferences.shared.useImperial)
    }

    private var currentSegmentDistanceString: String {
        appState.currentSegmentDistance.toDistance(useImperial: Preferences.shared.useImperial)
    }

    private var bottomBarHeight: CGFloat {
        120
    }

    // MARK: - Actions

    /// Adds a waypoint at the current user location.
    private func addPinAtMyLocation() {
        guard let mapView = appState.mapView else { return }
        let altitude = locationViewModel.lastLocation?.altitude
        let coord = locationViewModel.lastLocation?.coordinate ?? mapView.userLocation.coordinate
        let waypoint = GPXWaypoint(coordinate: coord, altitude: altitude)
        mapView.addWaypoint(waypoint)
        mapView.coreDataHelper.add(toCoreData: waypoint)
        appState.hasWaypoints = true
    }

    /// Presents a save alert with a text field for the filename.
    private func presentSaveAlert() {
        saveFileName = appState.lastGpxFilename.isEmpty
            ? appState.defaultFilename()
            : appState.lastGpxFilename
        showSaveAlert = false

        let alert = UIAlertController(
            title: NSLocalizedString("SAVE_AS", comment: "no comment"),
            message: NSLocalizedString("ENTER_SESSION_NAME", comment: "no comment"),
            preferredStyle: .alert
        )
        alert.addTextField { tf in
            tf.clearButtonMode = .always
            tf.text = saveFileName
        }
        let save = UIAlertAction(title: NSLocalizedString("SAVE", comment: "no comment"),
                                 style: .default) { _ in
            let name = (alert.textFields?[0].text?.isEmpty == false)
                ? alert.textFields![0].text!
                : appState.defaultFilename()
            appState.saveSession(withName: name, resetAfterSave: resetAfterSave)
            resetAfterSave = false
            toastPresenter.success("\(name).gpx saved")
        }
        let cancel = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "no comment"),
                                   style: .cancel) { _ in
            resetAfterSave = false
        }
        alert.addAction(save)
        alert.addAction(cancel)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }

    /// Shows the reset action sheet.
    private func presentResetAction() {
        showResetAction = true
    }

    /// Generates a temporary GPX file and presents the share sheet.
    private func shareGPX() {
        guard let url = appState.shareGPX() else { return }
        shareURL = url
        showShareSheet = true
    }
}

// MARK: - ShareSheet UIViewControllerRepresentable

/// Wraps `UIActivityViewController` for use in SwiftUI.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - CompassButtonView UIViewRepresentable

/// Wraps `MKCompassButton` for use in SwiftUI, positioned underneath the signal level.
struct CompassButtonView: UIViewRepresentable {
    weak var mapView: GPXMapView?

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.isUserInteractionEnabled = true
        return container
    }

    func updateUIView(_ container: UIView, context: Context) {
        if container.subviews.isEmpty, let mapView = mapView {
            let compass = MKCompassButton(mapView: mapView)
            compass.compassVisibility = .adaptive
            compass.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(compass)
            NSLayoutConstraint.activate([
                compass.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                compass.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                compass.widthAnchor.constraint(equalToConstant: 36),
                compass.heightAnchor.constraint(equalToConstant: 36)
            ])
        }
    }
}
