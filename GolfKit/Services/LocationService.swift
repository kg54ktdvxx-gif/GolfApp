import Foundation
import CoreLocation

@MainActor
public final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published public var location: CLLocation?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func getCurrentLocation() async throws -> CLLocation {
        if let location = location {
            return location
        }
        
        // If no location yet, we could wait for one, but for simplicity in this MVP:
        // We'll trigger an update and return the last known or throw if unavailable immediately.
        // A more robust implementation would use a continuation to wait for the delegate callback.
        
        locationManager.startUpdatingLocation()
        
        guard let loc = locationManager.location else {
            throw LocationError.locationUnknown
        }
        
        return loc
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    public func getDistance(to coordinate: CLLocationCoordinate2D) -> Int {
        guard let currentLocation = location else { return 0 }
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return Int(currentLocation.distance(from: targetLocation))
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        self.location = newLocation
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

public enum LocationError: Error, LocalizedError {
    case locationUnknown
    case locationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .locationUnknown: return "Location unknown"
        case .locationFailed(let msg): return "Location failed: \(msg)"
        }
    }
}
