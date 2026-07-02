//
//  PreferencesView.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import SwiftUI
import UniformTypeIdentifiers
import CoreLocation
import MapCache
import CoreServices

/// SwiftUI view that replaces the UIKit `PreferencesTableViewController`.
///
/// Provides settings for units, screen, cache, map source, activity type,
/// default filename format, and GPX files folder location.
struct PreferencesView: View {

    // MARK: - Properties

    /// Reference to the central app state.
    @ObservedObject var appState: AppState

    /// Reference to the location view model.
    @ObservedObject var locationViewModel: LocationViewModel

    /// Cache size string for display.
    @State private var cachedSize: String = ""

    /// Whether the document picker for folder selection is shown.
    @State private var showFolderPicker = false

    /// Environment dismiss for closing the sheet.
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        Form {
            unitsSection
            screenSection
            cacheSection
            mapSourceSection
            activityTypeSection
            defaultNameSection
            gpxFilesLocationSection
            aboutSection
        }
        .navigationTitle(NSLocalizedString("PREFERENCES", comment: "no comment"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("DONE", comment: "no comment")) {
                    dismiss()
                }
            }
        }
        .onAppear {
            calculateCacheSize()
        }
        .fileImporter(isPresented: $showFolderPicker,
                      allowedContentTypes: [.folder],
                      allowsMultipleSelection: false) { result in
            if case .success(let urls) = result, let url = urls.first {
                Preferences.shared.gpxFilesFolderURL = url
            }
        }
    }

    // MARK: - Units Section

    private var unitsSection: some View {
        Section(header: Text(NSLocalizedString("UNITS", comment: "no comment"))) {
            Toggle(NSLocalizedString("USE_IMPERIAL_UNITS", comment: "no comment"),
                   isOn: Binding(
                    get: { Preferences.shared.useImperial },
                    set: { newValue in
                        Preferences.shared.useImperial = newValue
                        locationViewModel.useImperial = newValue
                        appState.mapView?.scaleBar?.useImperial = newValue
                    }
                   ))
        }
    }

    // MARK: - Screen Section

    private var screenSection: some View {
        Section(header: Text(NSLocalizedString("SCREEN", comment: "no comment"))) {
            Toggle(NSLocalizedString("KEEP_SCREEN_ALWAYS_ON", comment: "no comment"),
                   isOn: Binding(
                    get: { Preferences.shared.keepScreenAlwaysOn },
                    set: { newValue in
                        Preferences.shared.keepScreenAlwaysOn = newValue
                        UIApplication.shared.isIdleTimerDisabled = newValue
                    }
                   ))

            Toggle(NSLocalizedString("SHOW_SCALE_BAR", comment: "no comment"),
                   isOn: Binding(
                    get: { Preferences.shared.showScaleBar },
                    set: { newValue in
                        Preferences.shared.showScaleBar = newValue
                        appState.mapView?.scaleBar?.isHidden = !newValue
                    }
                   ))
        }
    }

    // MARK: - Cache Section

    private var cacheSection: some View {
        Section(header: Text(NSLocalizedString("CACHE", comment: "no comment"))) {
            Toggle(NSLocalizedString("OFFLINE_CACHE", comment: "no comment"),
                   isOn: Binding(
                    get: { Preferences.shared.useCache },
                    set: { newValue in
                        Preferences.shared.useCache = newValue
                        appState.mapView?.useCache = newValue
                    }
                   ))

            if !cachedSize.isEmpty {
                HStack {
                    Text(NSLocalizedString("CLEAR_CACHE", comment: "no comment"))
                        .foregroundColor(.red)
                    Spacer()
                    Text(cachedSize)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .contentShape(Rectangle())
                .onTapGesture { clearCache() }
            }
        }
    }

    // MARK: - Map Source Section

    private var mapSourceSection: some View {
        Section(header: Text(NSLocalizedString("MAP_SOURCE", comment: "no comment"))) {
            ForEach(0..<GPXTileServer.count, id: \.self) { index in
                let tileServer = GPXTileServer(rawValue: index)!
                Button(action: {
                    Preferences.shared.tileServerInt = index
                    appState.mapView?.tileServer = tileServer
                }) {
                    HStack {
                        Text(tileServer.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if index == Preferences.shared.tileServerInt {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Activity Type Section

    private var activityTypeSection: some View {
        Section(header: Text(NSLocalizedString("ACTIVITY_TYPE", comment: "no comment"))) {
            ForEach(1...CLActivityType.count, id: \.self) { rawValue in
                let activity = CLActivityType(rawValue: rawValue)!
                Button(action: {
                    Preferences.shared.locationActivityTypeInt = rawValue
                    locationViewModel.updateActivityType(rawValue)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(activity.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            Text(activity.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if rawValue == Preferences.shared.locationActivityTypeInt {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Default Name Section

    private var defaultNameSection: some View {
        let df = DefaultDateFormat()
        return Section(header: Text(NSLocalizedString("DEFAULT_NAME_SECTION", comment: "no comment"))) {
            NavigationLink(destination: DefaultNameSetupView()) {
                VStack(alignment: .leading) {
                    Text(Preferences.shared.dateFormatPreset == -1
                         ? Preferences.shared.dateFormatInput
                         : Preferences.shared.dateFormatPresetName)
                        .font(.body)
                    Text(df.getDate(processedFormat: Preferences.shared.dateFormat,
                                    useUTC: Preferences.shared.dateFormatUseUTC,
                                    useENLocale: Preferences.shared.dateFormatUseEN))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - GPX Files Location Section

    private var gpxFilesLocationSection: some View {
        Section(header: Text(NSLocalizedString("GPX_FILES_FOLDER", comment: "no comment"))) {
            Button(action: { showFolderPicker = true }) {
                HStack {
                    Text(Preferences.shared.gpxFilesFolderURL?.lastPathComponent
                         ?? NSLocalizedString("USING_DEFAULT_FOLDER", comment: "no comment"))
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            NavigationLink(destination: AboutView()) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                    Text(NSLocalizedString("ABOUT", comment: "no comment"))
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // MARK: - Cache Helpers

    private func calculateCacheSize() {
        let config = MapCacheConfig(withUrlTemplate: "")
        let cache = MapCache(withConfig: config)
        DispatchQueue.global(qos: .background).async {
            let size = cache.diskCache.fileSize ?? 0
            DispatchQueue.main.async {
                cachedSize = Int(size).asFileSize()
            }
        }
    }

    private func clearCache() {
        let config = MapCacheConfig(withUrlTemplate: "")
        let cache = MapCache(withConfig: config)
        cache.clear {
            DispatchQueue.main.async {
                cachedSize = 0.asFileSize()
            }
        }
    }
}
