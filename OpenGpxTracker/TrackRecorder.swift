import CoreLocation

public protocol TrackRecorderDelegate: NSObjectProtocol {
    func trackRecorder(recorder: TrackRecorder, didUpdateToLocation newLocation: CLLocation)
}

public class TrackRecorder: NSObject, CLLocationManagerDelegate {
    weak var delegate: TrackRecorderDelegate?
    
    public var currentCoordinate: CLLocationCoordinate2D {
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
    
    public func start() {
        locationManager.startUpdatingLocation()
    }
    
    public func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError\(error)")
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        //        print("didUpdateToLocation \(newLocation.coordinate.latitude),\(newLocation.coordinate.longitude),",
        //            "Hacc: \(newLocation.horizontalAccuracy), Vacc: \(newLocation.verticalAccuracy)")
        
        delegate?.trackRecorder(self, didUpdateToLocation: newLocation)
    }
}