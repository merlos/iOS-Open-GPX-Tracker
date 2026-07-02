//
//  ControlBarView.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import SwiftUI

/// The bottom bar that contains the tracking, pin, follow, save and reset controls.
struct ControlBarView: View {

    // MARK: - Properties

    /// Reference to the central app state.
    @ObservedObject var appState: AppState

    /// Closure called when the add‑pin button is tapped.
    var onAddPin: (() -> Void)?

    /// Closure called when the save button is tapped.
    var onSave: (() -> Void)?

    /// Closure called when the reset button is tapped.
    var onReset: (() -> Void)?

    // MARK: - Constants

    private let buttonSmall: CGFloat = 48
    private let buttonLarge: CGFloat = 96
    private let separation: CGFloat = 6

    // MARK: - Body

    var body: some View {
        HStack(alignment: .center, spacing: separation) {
            // Follow user button
            followButton

            // Add pin button
            pinButton

            // Tracker button (large, centered)
            trackerButton

            // Save button
            saveButton

            // Reset button
            resetButton
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    // MARK: - Follow Button

    private var followButton: some View {
        Button(action: {
            appState.toggleFollowUser()
        }) {
            Image(appState.followUser ? "follow_user_high" : "follow_user")
                .resizable()
                .frame(width: 24, height: 24)
                .frame(width: buttonSmall, height: buttonSmall)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
        }
    }

    // MARK: - Pin Button

    private var pinButton: some View {
        Button(action: { onAddPin?() }) {
            Image("addPin")
                .resizable()
                .frame(width: 24, height: 24)
                .frame(width: buttonSmall, height: buttonSmall)
                .background(Color.white.opacity(0.9))
                .clipShape(Circle())
        }
    }

    // MARK: - Tracker Button

    private var trackerButton: some View {
        Button(action: { appState.trackerButtonTapped() }) {
            Text(trackerTitle)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: buttonLarge, height: buttonLarge)
                .background(trackerColor)
                .clipShape(Circle())
        }
    }

    private var trackerTitle: String {
        switch appState.gpxTrackingStatus {
        case .notStarted: return NSLocalizedString("START_TRACKING", comment: "no comment")
        case .tracking:   return NSLocalizedString("PAUSE", comment: "no comment")
        case .paused:     return NSLocalizedString("RESUME", comment: "no comment")
        }
    }

    private var trackerColor: Color {
        switch appState.gpxTrackingStatus {
        case .notStarted: return Color(red: 142/255, green: 224/255, blue: 102/255)
        case .tracking:   return Color(red: 146/255, green: 166/255, blue: 218/255)
        case .paused:     return Color(red: 142/255, green: 224/255, blue: 102/255)
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: { onSave?() }) {
            Text(NSLocalizedString("SAVE", comment: "no comment"))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: buttonSmall, height: buttonSmall)
                .background(saveEnabled ? Color(red: 74/255, green: 144/255, blue: 226/255)
                                        : Color(red: 74/255, green: 144/255, blue: 226/255).opacity(0.1))
                .clipShape(Circle())
        }
        .disabled(!saveEnabled)
    }

    private var saveEnabled: Bool {
        appState.gpxTrackingStatus != .notStarted || appState.hasWaypoints
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button(action: { onReset?() }) {
            Text(NSLocalizedString("RESET", comment: "no comment"))
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .frame(width: buttonSmall, height: buttonSmall)
                .background(resetEnabled ? Color(red: 244/255, green: 94/255, blue: 94/255)
                                        : Color(red: 244/255, green: 94/255, blue: 94/255).opacity(0.1))
                .clipShape(Circle())
        }
        .disabled(!resetEnabled)
    }

    private var resetEnabled: Bool {
        appState.gpxTrackingStatus != .notStarted || appState.hasWaypoints
    }
}
