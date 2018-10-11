import ObjectMapper
import CoreLocation

struct Stop: ImmutableMappable {

    let id: String
    let lat: Double
    let lon: Double

    private let _name: String
    var name: String { return _name.components(separatedBy: ",")[0] }

    var city: String {
        let components = _name.components(separatedBy: ",")

        if (components.count > 1) {
            return components[1]
        } else {
            return ""
        }
    }

    private let _type: VasttrafikEnum.StopType?
    var type: VasttrafikEnum.StopType { return _type ?? .stop }

    private let _idx: Int?
    var idx: Int { return _idx ?? 0 }

    var distance: Double {
        guard let currentLocation = CLLocation.latest else { return 0 }
        return currentLocation.distance(from: location)
    }

    var location: CLLocation {
        return CLLocation(latitude: lat, longitude: lon)
    }

    init(map: Map) throws {
        id = try map.value("id", using: VasttrafikTransform.filterStopId())
        lat = try map.value("lat", using: VasttrafikTransform.toDouble())
        lon = try map.value("lon", using: VasttrafikTransform.toDouble())
        _name = try map.value("name")
        _idx = try? map.value("idx", using: VasttrafikTransform.toInt())
        _type = try? map.value("type", using: VasttrafikTransform.stopType())
    }
    
    mutating func mapping(map: Map) {
        id >>> (map["id"], VasttrafikTransform.filterStopId())
        lat >>> (map["lat"], VasttrafikTransform.toDouble())
        lon >>> (map["lon"], VasttrafikTransform.toDouble())
        _name >>> (map["name"])
        _idx >>> (map["idx"], VasttrafikTransform.toInt())
        _type >>> (map["type"], VasttrafikTransform.stopType())
    }
}

extension Stop: VasttrafikArrayMappable {

    static func jsonToArray(_ json: JSON) -> [Stop] {
        var stops = [Stop]()

        guard let locationList = json["LocationList"] as? JSON else { return stops }

        if let stopLocation = locationList["StopLocation"] as? [JSON] {
            stopLocation.forEach { json in
                do { stops.append(try Mapper<Stop>().map(JSON: json)) } catch {}
            }
        } else if let stopLocation = locationList["StopLocation"] as? JSON {
            do { stops.append(try Mapper<Stop>().map(JSON: stopLocation)) } catch {}
        }

        if let coordLocation = locationList["CoordLocation"] as? [JSON] {
            coordLocation.forEach { json in
                do { stops.append(try Mapper<Stop>().map(JSON: json)) } catch {}
            }
        } else if let coordLocation = locationList["CoordLocation"] as? JSON {
            do { stops.append(try Mapper<Stop>().map(JSON: coordLocation)) } catch {}
        }

        return stops.sorted { $0.idx < $1.idx }
    }
}

extension Stop {

    static func userDefaultsJsonToStop(_ json: JSON) -> Stop? {
        return Mapper<Stop>().map(JSON: json)
    }

    static func userDefaultsJsonToStops(_ json: [JSON]) -> [Stop] {
        return json.compactMap { userDefaultsJsonToStop($0) }
    }
    
    private static func stopFromUserDefaults(key: Constants.UserDefaults) -> Stop? {
        if let json = UserDefaults.standard.dictionary(forKey: key.rawValue) {
            return userDefaultsJsonToStop(json)
        }
    
        return nil
    }
    
    private static func stopsFromUserDefaults(key: Constants.UserDefaults) -> [Stop] {
        if let json = UserDefaults.standard.array(forKey: key.rawValue) as? [JSON] {
            return userDefaultsJsonToStops(json)
        }
        
        return []
    }
}

extension Stop {

    static var closestOrigins: [Stop] {
        return stopsFromUserDefaults(key: .closestOrigins)
    }

    static var searchedDestinations: [Stop] {
        return stopsFromUserDefaults(key: .searchedDestinations)
    }

    static var searchedOrigins: [Stop] {
        return stopsFromUserDefaults(key: .searchedOrigins)
    }

    static var currentOrigin: Stop? {
        return stopFromUserDefaults(key: .currentOrigin)
    }

    static var currentDestinations: [Stop]? {
        let stops = stopsFromUserDefaults(key: .currentDestinations)
        return stops.isEmpty ? nil : stops
    }

    static var currentSearches: [Stop]? {
        let stops = stopsFromUserDefaults(key: .currentSearches)
        return stops.isEmpty ? nil : stops
    }
}

extension Stop {

    func saveSearchedDestination() {
        var stopsToSave = [self]
        StopDataHandler.shared.searchedDestinations.forEach { stop in
            if self != stop {
                stopsToSave.append(stop)
            }
        }

        stopsToSave.saveSearchedDestinations()
    }

    func saveSearchedOrigin() {
        var stopsToSave = [self]
        StopDataHandler.shared.searchedOrigins.forEach { stop in
            if self != stop {
                stopsToSave.append(stop)
            }
        }

        stopsToSave.saveSearchedOrigins()
    }

    func saveCurrentOrigin() {
        UserDefaults.standard.set(toJSON(), key: .currentOrigin)
        StopDataHandler.shared.currentOrigin = self
    }

    func saveCurrentSearch() {
        var stopsToSave = [self]
        StopDataHandler.shared.currentSearches?.forEach { stop in
            if self != stop {
                stopsToSave.append(stop)
            }
        }

        stopsToSave.saveCurrentSearches()
    }

    func removeCurrentSearch() {
        if var stops = StopDataHandler.shared.currentSearches, let index = stops.index(of: self) {
            stops.remove(at: index)
            stops.isEmpty ? Stop.removeCurrentSearches() : stops.saveCurrentSearches()
        }
    }

    static func removeCurrentOrigin() {
        UserDefaults.standard.removeObject(key: .currentOrigin)
        StopDataHandler.shared.currentOrigin = nil
    }

    static func removeClosestOrigins() {
        UserDefaults.standard.removeObject(key: .closestOrigins)
        StopDataHandler.shared.closestOrigins = [Stop]()
    }

    static func removeCurrentSearches() {
        UserDefaults.standard.removeObject(key: .currentSearches)
        StopDataHandler.shared.currentSearches = nil
        Favorite.removeCurrent()
    }
}

extension Stop: Equatable {

    static func ==(lhs: Stop, rhs: Stop) -> Bool {
        return lhs.id == rhs.id
    }
}
