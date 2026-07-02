//
//  DefaultNameSetupView.swift
//  OpenGpxTracker
//
//  Created by merlos during SwiftUI refactoring 02/Jul/2026
//

import SwiftUI

/// SwiftUI view that replaces the UIKit `DefaultNameSetupViewController`.
///
/// Allows the user to configure the default GPX filename format via a
/// text field with date pattern presets and formatting settings (UTC, English locale).
struct DefaultNameSetupView: View {

    // MARK: - Properties

    /// The text entered by the user as the date format.
    @State private var inputText: String = Preferences.shared.dateFormatInput

    /// Whether to use UTC time instead of local time.
    @State private var useUTC: Bool = Preferences.shared.dateFormatUseUTC

    /// Whether to force the English locale for date names.
    @State private var useEN: Bool = Preferences.shared.dateFormatUseEN

    /// Currently selected preset index.
    @State private var selectedPreset: Int = Preferences.shared.dateFormatPreset

    /// Processed date format string.
    @State private var processedFormat: String = ""

    /// Whether the format is invalid.
    @State private var isInvalid: Bool = false

    /// The date formatter helper.
    private let dateFormatter = DefaultDateFormat()

    /// Built-in presets.
    private let presets: [(name: String, format: String, input: String)] = [
        ("Defaults", "dd-MMM-yyyy-HHmm", "{dd}-{MMM}-{yyyy}-{HH}{mm}"),
        ("ISO8601 (UTC)", "yyyy-MM-dd'T'HH:mm:ss'Z'", "{yyyy}-{MM}-{dd}T{HH}:{mm}:{ss}Z"),
        ("ISO8601 (UTC offset)", "yyyy-MM-dd'T'HH:mm:ssZ", "{yyyy}-{MM}-{dd}T{HH}:{mm}:{ss}{Z}"),
        ("Day, Date at time (12 hr)", "EEEE, MMM d, yyyy 'at' h:mm a",
         "{EEEE}, {MMM} {d}, {yyyy} at {h}:{mm} {a}"),
        ("Day, Date at time (24 hr)", "EEEE, MMM d, yyyy 'at' HH:mm",
         "{EEEE}, {MMM} {d}, {yyyy} at {HH}:{mm}")
    ]

    // MARK: - Body

    var body: some View {
        Form {
            inputSection
            settingsSection
            presetsSection
        }
        .navigationTitle(NSLocalizedString("DEFAULT_NAME_DATE_FORMAT", comment: "no comment"))
        .onAppear(perform: updateProcessedFormat)
        .onChange(of: inputText) { _ in updateProcessedFormat() }
        .onChange(of: useUTC) { _ in updateProcessedFormat() }
        .onChange(of: useEN) { _ in updateProcessedFormat() }
    }

    // MARK: - Input Section

    private var inputSection: some View {
        Section {
            // Sample output
            HStack {
                Text(NSLocalizedString("DEFAULT_NAME_SAMPLE_OUTPUT_TITLE", comment: "no comment"))
                Spacer()
                Text(sampleOutput)
                    .font(.body.bold())
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }

            // Text input
            TextField(NSLocalizedString("DEFAULT_NAME_DATE_FORMAT", comment: "no comment"),
                      text: $inputText)
                .autocorrectionDisabled(true)
                .onSubmit { saveFormat() }
        } header: {
            Text(NSLocalizedString("DEFAULT_NAME_DATE_FORMAT", comment: "no comment"))
        } footer: {
            Text(NSLocalizedString("DEFAULT_NAME_INPUT_FOOTER", comment: "no comment"))
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        Section(header: Text(NSLocalizedString("DEFAULT_NAME_SETTINGS", comment: "no comment"))) {
            Toggle(NSLocalizedString("DEFAULT_NAME_USE_UTC", comment: "no comment"),
                   isOn: Binding(
                    get: { useUTC },
                    set: { newValue in
                        useUTC = newValue
                        Preferences.shared.dateFormatUseUTC = newValue
                    }
                   ))
                .disabled(selectedPreset == 1) // ISO8601 (UTC) preset forces UTC

            if Locale.current.languageCode != "en" {
                Toggle(NSLocalizedString("DEFAULT_NAME_ENGLISH_LOCALE", comment: "no comment"),
                       isOn: Binding(
                        get: { useEN },
                        set: { newValue in
                            useEN = newValue
                            Preferences.shared.dateFormatUseEN = newValue
                        }
                       ))
            }
        }
    }

    // MARK: - Presets Section

    private var presetsSection: some View {
        Section(header: Text(NSLocalizedString("DEFAULT_NAME_PRESET", comment: "no comment"))) {
            ForEach(presets.indices, id: \.self) { index in
                let preset = presets[index]
                Button(action: { selectPreset(at: index) }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .foregroundColor(.primary)
                            Text(dateFormatter.getDate(
                                processedFormat: preset.format,
                                useUTC: useUTC,
                                useENLocale: useEN
                            ))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                        if index == selectedPreset {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var sampleOutput: String {
        guard !isInvalid, !processedFormat.isEmpty else {
            return NSLocalizedString("DEFAULT_NAME_INPUT_FOOTER", comment: "no comment")
        }
        return dateFormatter.getDate(processedFormat: processedFormat,
                                     useUTC: useUTC,
                                     useENLocale: useEN)
    }

    private func updateProcessedFormat() {
        let result = dateFormatter.getDateFormat(unprocessed: inputText)
        processedFormat = result.0
        isInvalid = result.1
    }

    private func saveFormat() {
        guard !isInvalid, !inputText.isEmpty, !processedFormat.isEmpty else { return }
        Preferences.shared.dateFormat = processedFormat
        Preferences.shared.dateFormatInput = inputText
        Preferences.shared.dateFormatPreset = selectedPreset
        Preferences.shared.dateFormatUseUTC = useUTC
        Preferences.shared.dateFormatUseEN = useEN
    }

    private func selectPreset(at index: Int) {
        selectedPreset = index
        inputText = presets[index].input
        Preferences.shared.dateFormatPreset = index
        Preferences.shared.dateFormatInput = presets[index].input
        updateProcessedFormat()
        Preferences.shared.dateFormat = processedFormat

        if index == 1 { // ISO8601 (UTC) preset
            useUTC = true
            Preferences.shared.dateFormatUseUTC = true
        }
        saveFormat()
    }
}
