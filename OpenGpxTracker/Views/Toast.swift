//
//  Toast.swift
//  OpenGpxTracker
//
//  Created by Merlos on 5/28/23.
//  Converted to SwiftUI by Assistant on 7/1/26.
//

import Foundation
import SwiftUI

/// A SwiftUI representation of a toast notification system.
///
/// This file provides a SwiftUI-native API that mirrors the original UIKit-based
/// functionality: transient toasts with configurable style, position, and delay,
/// plus a persistent loading toast that can be shown/hidden manually.
///
/// Usage:
/// - Create and keep an instance of `ToastPresenter` in your app/root view (e.g. `@StateObject`).
/// - Overlay `ToastOverlay(presenter:)` on top of your view hierarchy.
/// - Trigger toasts via the presenter's convenience methods, such as `regular(_:)`, `info(_:)`, etc.
///
/// The API maintains method names and behavior similar to the original `Toast` class while
/// adopting SwiftUI patterns and avoiding direct window manipulation.

// MARK: - Toast Model and Styling

/// The vertical position of a toast within the screen.
public enum ToastPosition {
    /// Positions the toast near the bottom edge of the screen.
    case bottom
    /// Positions the toast in the vertical center of the screen.
    case center
    /// Positions the toast near the top edge of the screen.
    case top
}

/// Configuration for a single toast presentation.
public struct ToastConfiguration: Equatable {
    /// The message to display in the toast.
    public var message: String
    /// The foreground text color for the toast.
    public var textColor: Color
    /// The background color for the toast.
    public var backgroundColor: Color
    /// The vertical position for the toast.
    public var position: ToastPosition
    /// The time in seconds that the toast will be displayed. Use `ToastPresenter.kDisabledDelay` for persistent toasts.
    public var delay: Double
}

// MARK: - Presenter

/// An observable presenter that manages showing and hiding toasts.
///
/// Attach this to your root view (e.g. as a `@StateObject`) and pass it into `ToastOverlay`.
/// Call the presenter's methods to show toasts. The overlay reads state and animates accordingly.
public final class ToastPresenter: ObservableObject {
    // MARK: Public constants (mirroring original API)

    /// Short delay (in seconds) used for toasts that should disappear quickly.
    public static let kDelayShort: Double = 2.0
    /// Long delay (in seconds) used for toasts that should remain visible longer.
    public static let kDelayLong: Double = 5.0
    /// Special delay value that disables auto-dismiss behavior (persistent toast).
    public static let kDisabledDelay: Double = -1.0
    /// Background opacity applied to the original color constants.
    public static let kBackgroundOpacity: Double = 0.9
    /// Vertical padding added to the toast content.
    public static let kToastVerticalPadding: CGFloat = 10
    /// Horizontal padding added to the toast content.
    public static let kToastHorizontalPadding: CGFloat = 15
    /// Corner radius applied to the toast background.
    public static let kCornerRadius: CGFloat = 10
    /// Offset from the closest screen edge (top or bottom).
    public static let kToastOffset: CGFloat = 120
    /// Base font size for the toast text.
    public static let kFontSize: CGFloat = 16

    /// Default text color for a regular toast.
    public static let kRegularTextColor: Color = .white
    /// Default background color for a regular toast.
    public static let kRegularBackgroundColor: Color = .black.opacity(kBackgroundOpacity)

    /// Text color for an info toast.
    public static let kInfoTextColor: Color = .white
    /// Background color for an info toast.
    public static let kInfoBackgroundColor: Color = Color(red: 0/255, green: 100/255, blue: 225/255).opacity(kBackgroundOpacity)

    /// Text color for a success toast.
    public static let kSuccessTextColor: Color = .white
    /// Background color for a success toast.
    public static let kSuccessBackgroundColor: Color = Color(red: 0/255, green: 150/255, blue: 0/255).opacity(kBackgroundOpacity)

    /// Text color for a warning toast.
    public static let kWarningTextColor: Color = .black
    /// Background color for a warning toast.
    public static let kWarningBackgroundColor: Color = Color(red: 255/255, green: 175/255, blue: 0/255).opacity(kBackgroundOpacity)

    /// Text color for an error toast.
    public static let kErrorTextColor: Color = .white
    /// Background color for an error toast.
    public static let kErrorBackgroundColor: Color = Color(red: 175/255, green: 0/255, blue: 0/255).opacity(kBackgroundOpacity)

    // MARK: Published state

    /// The current configuration to display, or `nil` if no toast is visible.
    @Published public var current: ToastConfiguration? = nil
    /// Whether the toast overlay should be visible.
    @Published public var isVisible: Bool = false

    // MARK: Private timer storage

    /// The timer used to auto-dismiss a toast when `delay` is positive.
    private var dismissalTask: Task<Void, Never>? = nil

    // MARK: Toast API (mirroring original static methods)

    /// Shows a generic toast with the provided styling and behavior.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - textColor: Foreground text color.
    ///   - backgroundColor: Background color.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds that the toast will be displayed. Use `kDisabledDelay` for persistent toasts.
    public func showToast(_ message: String,
                          textColor: Color = ToastPresenter.kRegularTextColor,
                          backgroundColor: Color = ToastPresenter.kRegularBackgroundColor,
                          position: ToastPosition = .bottom,
                          delay: Double = ToastPresenter.kDelayLong) {
        // Cancel any existing dismissal task before showing a new toast.
        dismissalTask?.cancel()

        let config = ToastConfiguration(message: message,
                                        textColor: textColor,
                                        backgroundColor: backgroundColor,
                                        position: position,
                                        delay: delay)
        withAnimation(.easeIn(duration: 0.3)) {
            self.current = config
            self.isVisible = true
        }

        if delay != ToastPresenter.kDisabledDelay {
            dismissalTask = Task { [weak self] in
                guard let self else { return }
                // Await the specified delay, then animate out.
                try? await Task.sleep(nanoseconds: UInt64(max(0, delay)) * 1_000_000_000)
                await MainActor.run {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.isVisible = false
                    }
                }
                // Wait for animation to finish before clearing content.
                try? await Task.sleep(nanoseconds: 350_000_000)
                await MainActor.run { self.current = nil }
            }
        }
    }

    /// Displays a regular toast (black background, white text).
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds the toast will be displayed.
    public func regular(_ message: String,
                        position: ToastPosition = .bottom,
                        delay: Double = ToastPresenter.kDelayLong) {
        showToast(message,
                  textColor: Self.kRegularTextColor,
                  backgroundColor: Self.kRegularBackgroundColor,
                  position: position,
                  delay: delay)
    }

    /// Displays an information toast (blue background, white text) with an info symbol.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds the toast will be displayed.
    public func info(_ message: String,
                     position: ToastPosition = .bottom,
                     delay: Double = ToastPresenter.kDelayLong) {
        showToast("\u{24D8}  " + message,
                  textColor: Self.kInfoTextColor,
                  backgroundColor: Self.kInfoBackgroundColor,
                  position: position,
                  delay: delay)
    }

    /// Displays a warning toast (orange background, black text) with a warning symbol.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds the toast will be displayed.
    public func warning(_ message: String,
                        position: ToastPosition = .bottom,
                        delay: Double = ToastPresenter.kDelayLong) {
        showToast("\u{26A0}  " + message,
                  textColor: Self.kWarningTextColor,
                  backgroundColor: Self.kWarningBackgroundColor,
                  position: position,
                  delay: delay)
    }

    /// Displays a success toast (green background, white text) with a checkmark symbol.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds the toast will be displayed.
    public func success(_ message: String,
                        position: ToastPosition = .bottom,
                        delay: Double = ToastPresenter.kDelayLong) {
        showToast("\u{2705}  " + message,
                  textColor: Self.kSuccessTextColor,
                  backgroundColor: Self.kSuccessBackgroundColor,
                  position: position,
                  delay: delay)
    }

    /// Displays an error toast (red background, white text) with a cross mark symbol.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds the toast will be displayed.
    public func error(_ message: String,
                      position: ToastPosition = .bottom,
                      delay: Double = ToastPresenter.kDelayLong) {
        showToast("\u{274C}  " + message,
                  textColor: Self.kErrorTextColor,
                  backgroundColor: Self.kErrorBackgroundColor,
                  position: position,
                  delay: delay)
    }

    /// Shows a persistent loading toast with a spinner-like indicator.
    /// - Parameters:
    ///   - message: Text message to display alongside the spinner symbol.
    ///   - position: Vertical position within the screen.
    public func showLoading(_ message: String = "Loading...",
                            position: ToastPosition = .center) {
        showToast("⌛️  " + message,
                  textColor: Self.kRegularTextColor,
                  backgroundColor: Self.kRegularBackgroundColor,
                  position: position,
                  delay: Self.kDisabledDelay)
    }
    /// Hides a persistent loading toast if currently visible.
    public func hideLoading() {
        dismissalTask?.cancel()
        withAnimation(.easeOut(duration: 0.3)) {
            self.isVisible = false
        }
        // Clear content after the fade-out.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            self.current = nil
        }
    }
}

// MARK: - Toast View and Overlay

/// A single toast view that renders the provided configuration.
public struct ToastView: View {
    /// The configuration describing content and style for the toast.
    public let config: ToastConfiguration

    /// Creates a new toast view with the provided configuration.
    /// - Parameter config: The configuration describing the toast.
    public init(config: ToastConfiguration) {
        self.config = config
    }

    public var body: some View {
        Text(config.message)
            .font(.system(size: ToastPresenter.kFontSize))
            .multilineTextAlignment(.center)
            .foregroundStyle(config.textColor)
            .padding(.vertical, ToastPresenter.kToastVerticalPadding)
            .padding(.horizontal, ToastPresenter.kToastHorizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: ToastPresenter.kCornerRadius)
                    .fill(config.backgroundColor)
            )
            .accessibilityLabel("Toast: \(config.message)")
    }
}

/// An overlay that positions and animates the toast within the safe area.
public struct ToastOverlay: View {
    /// The presenter that controls toast visibility and content.
    @ObservedObject public var presenter: ToastPresenter

    /// Creates a new overlay bound to a presenter.
    /// - Parameter presenter: The presenter managing toast state.
    public init(presenter: ToastPresenter) {
        self.presenter = presenter
    }

    public var body: some View {
        ZStack {
            if let current = presenter.current, presenter.isVisible {
                toastPositioned(for: current)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: presenter.isVisible)
        .allowsHitTesting(false)
    }

    /// Positions the toast based on the provided configuration.
    /// - Parameter config: The configuration controlling message, style, and position.
    /// - Returns: A view positioned according to `config.position` with appropriate edge offset.
    @ViewBuilder
    private func toastPositioned(for config: ToastConfiguration) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let horizontalPadding: CGFloat = 24
            let maxWidth = width - (horizontalPadding * 2)

            Group {
                ToastView(config: config)
                    .frame(maxWidth: maxWidth, alignment: .center)
                    .padding(.horizontal, horizontalPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment(for: config.position))
                    .padding(edgeInsets(for: config.position))
            }
        }
    }

    /// Computes the alignment for a given toast position.
    /// - Parameter position: The desired vertical position.
    /// - Returns: The corresponding frame alignment.
    private func alignment(for position: ToastPosition) -> Alignment {
        switch position {
        case .top: return .top
        case .center: return .center
        case .bottom: return .bottom
        }
    }

    /// Computes the padding from the nearest edge for a given position.
    /// - Parameter position: The desired vertical position.
    /// - Returns: Edge insets that add `ToastPresenter.kToastOffset` from the edge.
    private func edgeInsets(for position: ToastPosition) -> EdgeInsets {
        switch position {
        case .top:
            return EdgeInsets(top: ToastPresenter.kToastOffset, leading: 0, bottom: 0, trailing: 0)
        case .center:
            return EdgeInsets()
        case .bottom:
            return EdgeInsets(top: 0, leading: 0, bottom: ToastPresenter.kToastOffset, trailing: 0)
        }
    }
}

// MARK: - Backwards-compatible namespace (optional)

/// A backwards-compatible namespace that mirrors the original static API using a shared presenter.
///
/// Note: In SwiftUI, it's recommended to create and hold a `ToastPresenter` in your view hierarchy
/// rather than relying on a global singleton. This namespace exists to minimize migration friction.
public enum Toast {
    /// Shared presenter used by the static API.
    public static let shared: ToastPresenter = ToastPresenter()

    /// Displays a regular toast.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds that the toast will be displayed.
    public static func regular(_ message: String,
                               position: ToastPosition = .bottom,
                               delay: Double = ToastPresenter.kDelayLong) {
        shared.regular(message, position: position, delay: delay)
    }

    /// Displays an information toast.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds that the toast will be displayed.
    public static func info(_ message: String,
                            position: ToastPosition = .bottom,
                            delay: Double = ToastPresenter.kDelayLong) {
        shared.info(message, position: position, delay: delay)
    }

    /// Displays a warning toast.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds that the toast will be displayed.
    public static func warning(_ message: String,
                               position: ToastPosition = .bottom,
                               delay: Double = ToastPresenter.kDelayLong) {
        shared.warning(message, position: position, delay: delay)
    }

    /// Displays a success toast.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds that the toast will be displayed.
    public static func success(_ message: String,
                               position: ToastPosition = .bottom,
                               delay: Double = ToastPresenter.kDelayLong) {
        shared.success(message, position: position, delay: delay)
    }

    /// Displays an error toast.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    ///   - delay: Time in seconds that the toast will be displayed.
    public static func error(_ message: String,
                             position: ToastPosition = .bottom,
                             delay: Double = ToastPresenter.kDelayLong) {
        shared.error(message, position: position, delay: delay)
    }

    /// Shows a persistent loading toast with a spinner symbol.
    /// - Parameters:
    ///   - message: Text message to display.
    ///   - position: Vertical position within the screen.
    public static func showLoading(_ message: String = "Loading...",
                                   position: ToastPosition = .center) {
        shared.showLoading(message, position: position)
    }

    /// Hides the persistent loading toast if visible.
    public static func hideLoading() {
        shared.hideLoading()
    }
}

