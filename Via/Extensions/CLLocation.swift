import CoreLocation

extension CLLocation {

    var needsUpdate: Bool {
        guard let location = CLLocation.latest else { return true }
        return self.distance(from: location) > 25
    }

    static var latest: CLLocation? {
        if let dict = UserDefaults.standard.dictionary(forKey: Constants.UserDefaults.latestLocation.rawValue) {
            return CLLocation(latitude: dict["lat"] as! Double, longitude: dict["lon"] as! Double)
        }

        return nil
    }

    func saveLatest() {
        let dict = [
            "lat": coordinate.latitude,
            "lon": coordinate.longitude
        ]

        UserDefaults.standard.set(dict, key: .latestLocation).synchronize()
    }
}
