import Foundation
import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func locationService(_ service: LocationService, didDetermineSide side: DuelSide)
    func locationServiceDidFail(_ service: LocationService)
}

enum DuelSide: String {
    case east = "East"
    case west = "West"
}

class LocationService: NSObject {

    // The longitude that divides east from west
    private let midLongitude: Double = 34.817549168324334

    weak var delegate: LocationServiceDelegate?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func fetchLocation() {
        manager.requestLocation()
    }

    var authorizationStatus: CLAuthorizationStatus {
        return manager.authorizationStatus
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse ||
           manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    // Decide the side
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coord = locations.last?.coordinate else { return }
        manager.stopUpdatingLocation()

        let side: DuelSide = coord.longitude < midLongitude ? .west : .east
        delegate?.locationService(self, didDetermineSide: side)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationService error: \(error.localizedDescription)")
        delegate?.locationServiceDidFail(self)
    }
}
