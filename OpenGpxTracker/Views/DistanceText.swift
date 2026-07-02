import SwiftUI
import Foundation
import MapKit

/// A SwiftUI view to display distances.
///
/// - Uses meters for values under 1 km (e.g., "980m") and kilometers with two decimals for >= 1 km (e.g., "1.20km").
/// - If `useImperial` is true, it displays the distance in miles (e.g., "0.23mi").
///
/// This mirrors the behavior of the UIKit `DistanceLabel` by relying on the same
/// `CLLocationDistance.toDistance(useImperial:)` formatting helper.
public struct DistanceText: View {
    public var distance: CLLocationDistance
    public var useImperial: Bool

    public init(distance: CLLocationDistance, useImperial: Bool = false) {
        self.distance = distance
        self.useImperial = useImperial
    }

    public var body: some View {
        Text(distance.toDistance(useImperial: useImperial))
    }
}

#Preview("DistanceText Examples") {
    VStack(alignment: .leading, spacing: 12) {
        Group {
            Text("Metric")
                .font(.headline)
            DistanceText(distance: 980) // 980m
            DistanceText(distance: 1200) // 1.20km
            DistanceText(distance: 12_345) // 12.35km
        }
        Divider()
        Group {
            Text("Imperial")
                .font(.headline)
            DistanceText(distance: 980, useImperial: true) // ~0.61mi
            DistanceText(distance: 1609.34, useImperial: true) // 1.00mi
            DistanceText(distance: 42_195, useImperial: true) // ~26.22mi
        }
    }
    .padding()
}
