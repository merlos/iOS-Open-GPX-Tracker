//
//  GPXFilesView.swift
//  OpenGpxTracker
//
//  Created during SwiftUI refactoring
//

import SwiftUI
import UniformTypeIdentifiers
import CoreGPX
import CoreServices
import UIKit

/// SwiftUI view that replaces the UIKit `GPXFilesTableViewController`.
///
/// Displays the list of GPX files saved on disk and allows the user to
/// load, share, or delete them.  Also offers a folder picker to change
/// the GPX files directory.
struct GPXFilesView: View {

    // MARK: - Properties

    /// Reference to the central app state.
    @ObservedObject var appState: AppState

    /// The list of file info objects.
    @State private var fileList: [GPXFileInfo] = []

    /// Error message for toast notification.
    @State private var showFileImporter = false

    /// Whether loading indicator is shown.
    @State private var isLoading = false

    /// File selected for action sheet.
    @State private var selectedFile: GPXFileInfo?

    /// Whether to show the action sheet.
    @State private var showActionSheet = false

    /// Environment dismiss action.
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        List {
            if fileList.isEmpty {
                Text(NSLocalizedString("NO_FILES", comment: "no comment"))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(fileList, id: \.fileURL) { fileInfo in
                    GPXFileRow(fileInfo: fileInfo)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFile = fileInfo
                            showActionSheet = true
                        }
                        .contextMenu { contextMenu(for: fileInfo) }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteFile(fileInfo)
                            } label: {
                                Label(NSLocalizedString("DELETE", comment: "no comment"),
                                      systemImage: "trash")
                            }
                        }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(NSLocalizedString("YOUR_FILES", comment: "no comment"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(NSLocalizedString("DONE", comment: "no comment")) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showFileImporter = true }) {
                    Image(systemName: "folder")
                }
            }
        }
        .fileImporter(isPresented: $showFileImporter,
                      allowedContentTypes: [.folder, .init(filenameExtension: "gpx")!].compactMap { $0 },
                      allowsMultipleSelection: false) { result in
            handleFileImport(result)
        }
        .onAppear(perform: reloadFiles)
        .confirmationDialog(
            NSLocalizedString("FILE_OPTIONS", comment: "no comment"),
            isPresented: $showActionSheet,
            presenting: selectedFile
        ) { fileInfo in
            Button(NSLocalizedString("LOAD_IN_MAP", comment: "no comment")) {
                loadFile(fileInfo)
            }
            Button(NSLocalizedString("SHARE", comment: "no comment")) {
                shareFile(fileInfo)
            }
            Button(NSLocalizedString("CANCEL", comment: "no comment"), role: .cancel) {}
            Button(NSLocalizedString("DELETE", comment: "no comment"), role: .destructive) {
                deleteFile(fileInfo)
            }
        }
        .overlay {
            if isLoading {
                ProgressView(NSLocalizedString("LOADING_FILE", comment: "no comment"))
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
    }

    // MARK: - Row

    struct GPXFileRow: View {
        let fileInfo: GPXFileInfo

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text(fileInfo.fileName)
                    .font(.body)
                let lastSaved = NSLocalizedString("LAST_SAVED", comment: "no comment")
                Text(String(format: lastSaved,
                           fileInfo.modifiedDatetimeAgo,
                           fileInfo.fileSizeHumanised))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenu(for fileInfo: GPXFileInfo) -> some View {
        Button {
            loadFile(fileInfo)
        } label: {
            Label(NSLocalizedString("LOAD_IN_MAP", comment: "no comment"),
                  systemImage: "square.and.arrow.down")
        }

        Button {
            shareFile(fileInfo)
        } label: {
            Label(NSLocalizedString("SHARE", comment: "no comment"),
                  systemImage: "square.and.arrow.up")
        }

        Divider()

        Button(role: .destructive) {
            deleteFile(fileInfo)
        } label: {
            Label(NSLocalizedString("DELETE", comment: "no comment"),
                  systemImage: "trash")
        }
    }

    // MARK: - Actions

    private func loadFile(_ fileInfo: GPXFileInfo) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let folderURL = GPXFileManager.GPXFilesFolderURL
            let secured = folderURL.startAccessingSecurityScopedResource()
            if secured { defer { folderURL.stopAccessingSecurityScopedResource() } }

            guard let gpx = GPXParser(withURL: fileInfo.fileURL)?.parsedData() else {
                DispatchQueue.main.async {
                    isLoading = false
                    Toast.error("Could not open file")
                }
                return
            }
            DispatchQueue.main.async {
                isLoading = false
                appState.didLoadGPXFileWithName(
                    fileInfo.fileURL.deletingPathExtension().lastPathComponent,
                    gpxRoot: gpx
                )
                dismiss()
            }
        }
    }

    private func shareFile(_ fileInfo: GPXFileInfo) {
        let activityVC = UIActivityViewController(
            activityItems: [fileInfo.fileURL],
            applicationActivities: nil
        )
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX,
                                                                          y: window.bounds.midY,
                                                                          width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = []
            var top = rootVC
            while let presented = top.presentedViewController, !presented.isBeingDismissed {
                top = presented
            }
            top.present(activityVC, animated: true)
        }
    }

    private func deleteFile(_ fileInfo: GPXFileInfo) {
        GPXFileManager.removeFileFromURL(fileInfo.fileURL)
        reloadFiles()
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            if GPXFileManager.gpxExtList.contains(url.pathExtension) {
                loadGPXFileFromURL(url)
            } else {
                Preferences.shared.gpxFilesFolderURL = url
                reloadFiles()
            }
        case .failure:
            break
        }
    }

    private func loadGPXFileFromURL(_ url: URL) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            guard let gpx = GPXParser(withURL: url)?.parsedData() else {
                DispatchQueue.main.async {
                    isLoading = false
                    Toast.error("Could not open file")
                }
                return
            }
            let name = url.deletingPathExtension().lastPathComponent
            DispatchQueue.main.async {
                isLoading = false
                appState.didLoadGPXFileWithName(name, gpxRoot: gpx)
                dismiss()
            }
        }
    }

    private func reloadFiles() {
        fileList = GPXFileManager.fileList
    }
}

// MARK: - AppState GPX Loading Extension

extension AppState: GPXFilesTableViewControllerDelegate {
    func didLoadGPXFileWithName(_ gpxFilename: String, gpxRoot: GPXRoot) {
        // Emulate reset
        gpxTrackingStatus = .notStarted
        lastGpxFilename = gpxFilename
        mapView?.coreDataHelper.add(toCoreData: gpxFilename, willContinueAfterSave: false)
        stopWatch.reset()
        mapView?.importFromGPXRoot(gpxRoot)
        followUser = false
        mapView?.regionToGPXExtent()
        gpxTrackingStatus = .paused
        totalDistance = mapView?.session.totalTrackedDistance ?? 0
    }
}
