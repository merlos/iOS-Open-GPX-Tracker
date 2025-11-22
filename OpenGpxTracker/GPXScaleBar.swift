import UIKit
import MapKit

/// A custom scale view for MapKit that displays distance measurements with support for both imperial and metric units.
///
/// `GPXScaleBar` provides a visual representation of map scale, automatically updating as the map region changes.
/// Unlike `MKScaleView`, this implementation allows you to explicitly control whether imperial or metric units are used.
///
/// ## Usage
///
/// ```swift
/// let scaleBar = GPXScaleBar(mapView: mapView, useImperial: true)
/// view.addSubview(scaleBar)
///
/// NSLayoutConstraint.activate([
///     scaleBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
///     scaleBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
/// ])
/// ```
///
/// - Important: Remember to set your `MKMapView` delegate and call `updateForMapViewChange()` in the
///   `mapView(_:regionDidChangeAnimated:)` delegate method to keep the scale synchronized.
///
/// - Note: The scale view automatically adapts to light and dark mode using system colors.
class GPXScaleBar: UIView {
    
    // MARK: - Properties
    
    /// The map view that this scale view is associated with.
    public weak var mapView: MKMapView?
    
    /// Determines whether to use imperial (feet/miles) or metric (meters/kilometers) units.
    ///
    /// When this property changes, the scale bar automatically updates to reflect the new unit system.
    public var useImperial: Bool {
        didSet {
            if oldValue != useImperial {
                updateScale()
            }
        }
    }
    
    /// The horizontal bar representing the scale distance.
    private let scaleBar = UIView()
    
    /// Array of intermediate tick marks on the scale bar.
    private var ticks: [UIView] = []
    
    /// Array of labels for the scale divisions.
    private var labels: [UILabel] = []
    
    /// The height of the horizontal scale bar.
    private let barHeight: CGFloat = 4
    
    /// The width of the tick marks.
    private let tickWidth: CGFloat = 1
    
    /// The height of the tick marks.
    private let tickHeight: CGFloat = 8
    
    /// The internal padding around the scale view content.
    private let padding: CGFloat = 8
    
    /// Number of segments to display on the scale bar.
    private let numberOfSegments: Int = 2
    
    /// The constant width of the container (slightly bigger than max scale width)
    private let containerWidth: CGFloat = 320
    
    // MARK: - Initialization
    
    /// Creates a new custom scale bar for the specified map view.
    ///
    /// - Parameters:
    ///   - mapView: The `MKMapView` instance to display the scale for.
    ///   - useImperial: `true` to display imperial units (feet/miles), `false` for metric units (meters/kilometers).
    ///
    /// - Note: The scale bar will automatically observe map region changes and update accordingly.
    public init(mapView: MKMapView, useImperial: Bool) {
        self.mapView = mapView
        self.useImperial = useImperial
        super.init(frame: .zero)
        setupViews()
        setupObserver()
        updateScale()
    }
    
    /// Creates a new custom scale bar without an associated map view.
    ///
    /// Use this initializer when you need to create the scale bar as a property before `self` is available,
    /// then call `configure(mapView:useImperial:)` to complete the setup.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class MapViewController: UIViewController {
    ///     let mapView = MKMapView()
    ///     let scaleBar = GPXScaleBar()
    ///
    ///     override func viewDidLoad() {
    ///         super.viewDidLoad()
    ///         scaleBar.configure(mapView: mapView, useImperial: preferences.useImperial)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter useImperial: `true` to display imperial units (feet/miles), `false` for metric units (meters/kilometers). Defaults to `true`.
    public convenience init(useImperial: Bool = true) {
        self.init(mapView: nil, useImperial: useImperial)
    }
    
    /// Internal initializer that allows for deferred configuration.
    private init(mapView: MKMapView?, useImperial: Bool) {
        self.mapView = mapView
        self.useImperial = useImperial
        super.init(frame: .zero)
        setupViews()
        if mapView != nil {
            setupObserver()
            updateScale()
        }
    }
    
    /// Initializer for use with Interface Builder (storyboards/XIBs).
    ///
    /// When using this initializer, you must call `configure(mapView:useImperial:)` after the view loads.
    ///
    /// - Parameter coder: An unarchiver object.
    required public init?(coder: NSCoder) {
        self.mapView = nil
        self.useImperial = true
        super.init(coder: coder)
        setupViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    /// Configures the visual appearance and layout of all scale view subviews.
    ///
    /// This method sets up:
    /// - Background styling with rounded corners and borders
    /// - Scale bar and endpoint caps
    /// - Distance labels with appropriate font and color
    private func setupViews() {
        // Configure background - transparent, no border
        backgroundColor = .clear
        
        // Configure scale bar
        if #available(iOS 13.0, *) {
            scaleBar.backgroundColor = .label
        } else {
            scaleBar.backgroundColor = .black
        }
        scaleBar.layer.cornerRadius = barHeight / 2
        addSubview(scaleBar)
        
        // Create ticks (numberOfSegments + 1 for start and end)
        for _ in 0...numberOfSegments {
            let tick = UIView()
            if #available(iOS 13.0, *) {
                tick.backgroundColor = .label
            } else {
                tick.backgroundColor = .black
            }
            tick.layer.cornerRadius = tickWidth / 2
            addSubview(tick)
            ticks.append(tick)
        }
        
        // Create labels (we'll show labels at strategic points)
        for _ in 0...numberOfSegments {
            let label = UILabel()
            label.font = .systemFont(ofSize: 11, weight: .medium)
            if #available(iOS 13.0, *) {
                label.textColor = .label
            } else {
                label.textColor = .black
            }
            label.textAlignment = .center
            addSubview(label)
            labels.append(label)
        }
        
        // Set intrinsic size
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Sets up notification observer for map region changes.
    ///
    /// Listens for `MKMapViewRegionDidChangeNotification` to automatically update the scale display.
    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(mapViewRegionDidChange),
            name: NSNotification.Name("MKMapViewRegionDidChangeNotification"),
            object: mapView
        )
    }
    
    /// Handles map region change notifications.
    ///
    /// This method is called automatically when the map's visible region changes.
    @objc private func mapViewRegionDidChange() {
        updateScale()
    }
    
    // MARK: - Scale Calculation
    
    /// Updates the scale display based on the current map region and zoom level.
    ///
    /// This method:
    /// 1. Calculates the real-world distance represented by screen points
    /// 2. Determines an appropriate scale distance to display
    /// 3. Updates the UI with the calculated values
    ///
    /// - Note: Called automatically when the map region changes, but can also be called manually via `updateForMapViewChange()`.
    private func updateScale() {
        guard let mapView = mapView else { return }
        
        // Calculate meters per point at center of map
        let centerPoint = CGPoint(x: mapView.bounds.midX, y: mapView.bounds.midY)
        let centerCoordinate = mapView.convert(centerPoint, toCoordinateFrom: mapView)
        
        // Calculate distance for 100 points horizontally
        let leftPoint = CGPoint(x: mapView.bounds.midX - 50, y: mapView.bounds.midY)
        let rightPoint = CGPoint(x: mapView.bounds.midX + 50, y: mapView.bounds.midY)
        
        let leftCoordinate = mapView.convert(leftPoint, toCoordinateFrom: mapView)
        let rightCoordinate = mapView.convert(rightPoint, toCoordinateFrom: mapView)
        
        let leftLocation = CLLocation(latitude: leftCoordinate.latitude, longitude: leftCoordinate.longitude)
        let rightLocation = CLLocation(latitude: rightCoordinate.latitude, longitude: rightCoordinate.longitude)
        
        let metersFor100Points = leftLocation.distance(from: rightLocation)
        let metersPerPoint = metersFor100Points / 100.0
        
        // Determine appropriate scale
        let (distance, width) = calculateScale(metersPerPoint: metersPerPoint)
        
        // Update UI
        updateUI(distance: distance, width: width)
    }
    
    /// Calculates an appropriate scale distance and bar width for the current map zoom level.
    ///
    /// - Parameter metersPerPoint: The number of meters represented by one screen point at the current zoom level.
    /// - Returns: A tuple containing the distance to display and the width of the scale bar in points.
    ///
    /// This method selects a "nice" round number for the scale distance (e.g., 100, 500, 1000)
    /// that fits within the maximum allowed width.
    private func calculateScale(metersPerPoint: Double) -> (distance: Double, width: CGFloat) {
        let maxWidth: CGFloat = 300
        let maxMeters = Double(maxWidth) * metersPerPoint
        
        if useImperial {
            return calculateImperialScale(maxMeters: maxMeters, metersPerPoint: metersPerPoint)
        } else {
            return calculateMetricScale(maxMeters: maxMeters, metersPerPoint: metersPerPoint)
        }
    }
    
    /// Calculates scale values using metric units (meters and kilometers).
    ///
    /// - Parameters:
    ///   - maxMeters: The maximum distance in meters that can fit within the scale bar.
    ///   - metersPerPoint: The number of meters represented by one screen point.
    /// - Returns: A tuple containing the distance in meters and the bar width in points.
    ///
    /// Selects from common metric intervals: 1, 2, 5, 10, 20, 50, 100, 200, 500m, and 1, 2, 5, 10, 20, 50, 100, 200, 500km.
    private func calculateMetricScale(maxMeters: Double, metersPerPoint: Double) -> (distance: Double, width: CGFloat) {
        let distances: [Double] = [
            1, 2, 5, 10, 20, 50, 100, 200, 500,
            1000, 2000, 5000, 10000, 20000, 50000,
            100000, 200000, 500000, 1000000
        ]
        
        for distance in distances {
            if distance <= maxMeters {
                let width = CGFloat(distance / metersPerPoint)
                if width >= 75 {
                    return (distance, width)
                }
            }
        }
        
        return (distances[0], 75)
    }
    
    /// Calculates scale values using imperial units (feet and miles).
    ///
    /// - Parameters:
    ///   - maxMeters: The maximum distance in meters that can fit within the scale bar.
    ///   - metersPerPoint: The number of meters represented by one screen point.
    /// - Returns: A tuple containing the distance in feet and the bar width in points.
    ///
    /// Selects from common imperial intervals: 1, 2, 5, 10, 20, 50, 100, 200, 500ft, and 1, 2, 5, 10, 20, 50, 100mi.
    /// One mile equals 5,280 feet.
    private func calculateImperialScale(maxMeters: Double, metersPerPoint: Double) -> (distance: Double, width: CGFloat) {
        let feetPerMeter = 3.28084
        let maxFeet = maxMeters * feetPerMeter
        
        // Distances in feet
        let distances: [Double] = [
            1, 2, 5, 10, 20, 50, 100, 200, 500,
            1000, 2000, 5280, // 1 mile
            10560, 26400, 52800, 105600, 264000, 528000
        ]
        
        for distance in distances {
            if distance <= maxFeet {
                let metersForDistance = distance / feetPerMeter
                let width = CGFloat(metersForDistance / metersPerPoint)
                if width >= 40 {
                    return (distance, width)
                }
            }
        }
        
        return (distances[0], 40)
    }
    
    /// Updates the visual layout of the scale view based on the calculated distance and width.
    ///
    /// - Parameters:
    ///   - distance: The distance to display (in feet for imperial, meters for metric).
    ///   - width: The width of the scale bar in points.
    ///
    /// This method:
    /// - Formats and displays the distance labels
    /// - Calculates the view's size to accommodate all elements
    /// - Positions the scale bar, endpoint caps, and labels
    private func updateUI(distance: Double, width: CGFloat) {
        // Calculate segment width
        let segmentWidth = width / CGFloat(numberOfSegments)
        
        // Update labels - show only 0 and final value
        let segmentDistance = distance / Double(numberOfSegments)
        
        // First, format all labels to check their sizes
        var labelTexts: [String] = []
        for index in 0...numberOfSegments {
            let value = segmentDistance * Double(index)
            if index == 0 {
                labelTexts.append("0")
            } else {
                labelTexts.append(formatDistance(value))
            }
        }
        
        // Size all labels
        for (index, label) in labels.enumerated() {
            label.text = labelTexts[index]
            label.sizeToFit()
        }
        
        // Show only first and last labels
        for (index, label) in labels.enumerated() {
            if index == 0 {
                // Show first label (0)
                label.isHidden = false
            } else if index == numberOfSegments {
                // Show last label
                label.isHidden = false
            } else {
                // Hide all intermediate labels
                label.isHidden = true
            }
        }
        
        // Calculate total dimensions with constant container size
        let labelSpace: CGFloat = 4
        let maxLabelHeight = labels.compactMap { $0.isHidden ? nil : $0.frame.height }.max() ?? 0
        let totalHeight = tickHeight + labelSpace + maxLabelHeight + padding * 2
        
        // Update frame to constant size
        frame.size = CGSize(width: containerWidth, height: totalHeight)
        
        // Calculate offset to center the scale bar within the container
        let horizontalOffset = (containerWidth - width) / 2
        
        // Position scale bar (centered horizontally, at top)
        let barY = padding
        scaleBar.frame = CGRect(
            x: horizontalOffset,
            y: barY + (tickHeight - barHeight) / 2,
            width: width,
            height: barHeight
        )
        
        // Position ticks and labels
        let labelY = barY + tickHeight + labelSpace
        
        for (index, tick) in ticks.enumerated() {
            let x = horizontalOffset + segmentWidth * CGFloat(index)
            
            tick.frame = CGRect(
                x: x - tickWidth / 2,
                y: barY,
                width: tickWidth,
                height: tickHeight
            )
            
            // Position corresponding label (centered under tick)
            if index < labels.count && !labels[index].isHidden {
                let label = labels[index]
                
                // Special positioning for first and last labels to prevent overflow
                var labelX = x - label.frame.width / 2
                
                if index == 0 {
                    // Align left edge with left tick
                    labelX = horizontalOffset
                } else if index == numberOfSegments {
                    // Align right edge with right tick
                    labelX = horizontalOffset + width - label.frame.width
                }
                
                label.frame = CGRect(
                    x: labelX,
                    y: labelY,
                    width: label.frame.width,
                    height: label.frame.height
                )
            }
        }
    }
    
    /// Formats a distance value into a human-readable string with appropriate units.
    ///
    /// - Parameter distance: The distance to format (in feet for imperial, meters for metric).
    /// - Returns: A formatted string such as "500 ft", "1.5 mi", "200 m", or "5.2 km".
    ///
    /// ## Formatting Rules
    ///
    /// **Imperial:**
    /// - Values under 5,280 feet display as feet (e.g., "500 ft")
    /// - Values 5,280 feet and above display as miles
    /// - Miles >= 10 show no decimal places (e.g., "15 mi")
    /// - Miles < 10 show one decimal place (e.g., "2.5 mi")
    ///
    /// **Metric:**
    /// - Values under 1,000 meters display as meters (e.g., "500 m")
    /// - Values 1,000 meters and above display as kilometers
    /// - Kilometers >= 10 show no decimal places (e.g., "15 km")
    /// - Kilometers < 10 show one decimal place (e.g., "2.5 km")
    private func formatDistance(_ distance: Double) -> String {
        if useImperial {
            if distance >= 5280 {
                let miles = distance / 5280
                if miles >= 10 {
                    return "\(Int(miles))mi"
                } else {
                    return String(format: "%.1fmi", miles)
                }
            } else {
                return "\(Int(distance))ft"
            }
        } else {
            if distance >= 1000 {
                let km = distance / 1000
                if km >= 10 {
                    return "\(Int(km))km"
                } else {
                    return String(format: "%.1fkm", km)
                }
            } else {
                return "\(Int(distance))m"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Configures the scale bar with a map view after initialization.
    ///
    /// Use this method when you've created the scale bar using `init(useImperial:)` and need to
    /// associate it with a map view later.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class MapViewController: UIViewController {
    ///     let mapView = MKMapView()
    ///     let scaleBar = GPXScaleBar() // Created without map view
    ///
    ///     override func viewDidLoad() {
    ///         super.viewDidLoad()
    ///         scaleBar.configure(mapView: mapView, useImperial: preferences.useImperial)
    ///         view.addSubview(scaleBar)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - mapView: The `MKMapView` instance to display the scale for.
    ///   - useImperial: `true` to display imperial units (feet/miles), `false` for metric units (meters/kilometers).
    ///
    /// - Important: Call this method before adding the scale bar to your view hierarchy to ensure proper display.
    public func configure(mapView: MKMapView, useImperial: Bool) {
        self.mapView = mapView
        self.useImperial = useImperial
        setupObserver()
        updateScale()
    }
    
    /// Manually triggers an update of the scale display.
    ///
    /// Call this method when the map view's region changes if you're not using automatic observation
    /// through the map view delegate.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    ///     scaleBar.updateForMapViewChange()
    /// }
    /// ```
    ///
    /// - Note: If you've set up the scale bar with automatic observation, this method is called automatically
    ///   and you don't need to call it manually.
    public func updateForMapViewChange() {
        updateScale()
    }
    
    /// Updates the unit system preference and refreshes the scale display.
    ///
    /// This is a convenience method for updating the `useImperial` property. You can either set
    /// `useImperial` directly or call this method - both will trigger an automatic update.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Option 1: Set property directly
    /// scaleBar.useImperial = preferences.useImperial
    ///
    /// // Option 2: Use this method
    /// scaleBar.updateUnits(useImperial: preferences.useImperial)
    /// ```
    ///
    /// - Parameter useImperial: `true` for imperial units (feet/miles), `false` for metric units (meters/kilometers).
    public func updateUnits(useImperial: Bool) {
        self.useImperial = useImperial
    }
}

// MARK: - Usage Example

/*
// OPTION 1: Initialize with map view directly (when map is available during init)

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    var scaleBar: GPXScaleBar!
    var preferences = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = view.bounds
        view.addSubview(mapView)
        mapView.delegate = self
        
        // Create with map view
        scaleBar = GPXScaleBar(mapView: mapView, useImperial: preferences.useImperial)
        view.addSubview(scaleBar)
        
        NSLayoutConstraint.activate([
            scaleBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scaleBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// OPTION 2: Declare as property and configure later (avoids "cannot use instance member" error)

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    let scaleBar = GPXScaleBar() // No map view needed at declaration
    var preferences = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = view.bounds
        view.addSubview(mapView)
        mapView.delegate = self
        
        // Configure the scale bar with map view
        scaleBar.configure(mapView: mapView, useImperial: preferences.useImperial)
        view.addSubview(scaleBar)
        
        NSLayoutConstraint.activate([
            scaleBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scaleBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // Called when returning from settings or when preferences change
    func preferencesDidChange() {
        scaleBar.useImperial = preferences.useImperial
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        scaleBar.updateForMapViewChange()
    }
}

struct Preferences {
    var useImperial: Bool = true
}

// MARK: - Settings Integration Example

class SettingsViewController: UIViewController {
    
    weak var mapViewController: MapViewController?
    var preferences = Preferences()
    
    @IBAction func unitsToggleChanged(_ sender: UISwitch) {
        preferences.useImperial = sender.isOn
        
        // Update the scale bar immediately
        mapViewController?.scaleBar.useImperial = preferences.useImperial
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Or update when leaving settings
        mapViewController?.preferencesDidChange()
    }
}
*/
