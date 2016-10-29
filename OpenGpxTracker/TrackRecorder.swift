import CoreLocation

public protocol TrackRecorderDelegate: NSObjectProtocol {
    func trackRecorder(_ recorder: TrackRecorder, didUpdateToLocation newLocation: CLLocation)
}

open class TrackRecorder: NSObject, CLLocationManagerDelegate {
    weak var delegate: TrackRecorderDelegate?
    
    open var currentCoordinate: CLLocationCoordinate2D {
        get {
            return locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        }
    }
    
    let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.requestAlwaysAuthorization()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2
        manager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        return manager
    }()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    open func start() {
        locationManager.startUpdatingLocation()
    }
    
    open func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError\(error)")
    }
    
    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.first!
        delegate?.trackRecorder(self, didUpdateToLocation: newLocation)

    }
}
