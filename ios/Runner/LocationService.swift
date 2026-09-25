import CoreLocation
import Flutter

class LocationService: NSObject, CLLocationManagerDelegate {

    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private(set) var isRunning = false

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
    }

    func startUpdates() {
        guard !isRunning else { return }

        let status = locationManager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            isRunning = true
            NSLog("LocationService: started")
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    func stopUpdates() {
        guard isRunning else { return }
        locationManager.stopUpdatingLocation()
        isRunning = false
        NSLog("LocationService: stopped")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "speed": max(location.speed, 0),
            "bearing": max(location.course, 0),
            "time": Int64(location.timestamp.timeIntervalSince1970 * 1000)
        ]

        LocationEventStreamHandler.shared.sendLocation(locationData)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("LocationService: error -> \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if !isRunning {
                startUpdates()
            }
        }
    }
}
