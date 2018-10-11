import Foundation
import ObjectMapper

struct Favorite {

    let id: String
    var name: String
    var stops: [Stop]

    var stopIds: [String] { return stops.map { $0.id } }
    var stopNames: [String] { return stops.map { $0.name } }

    init(id: String = String.random(), name: String, stops: [Stop]) {
        self.id = id
        self.name = name
        self.stops = stops
    }

    func toJson() -> JSON {
        let stopJson = stops.map { $0.toJSON() }
        return ["id": id, "name": name, "stops": stopJson]
    }

    private static func fromJson(_ json: JSON) -> Favorite {
        let id = json["id"] as! String
        let name = json["name"] as! String
        let stopJson = json["stops"] as! [JSON]
        return Favorite(id: id, name: name, stops: Stop.userDefaultsJsonToStops(stopJson))
    }
}

extension Favorite {

    mutating func add(stop: Stop) {
        if !stops.contains(stop) && stops.count < 4 {
            stops.append(stop)
        }

        stops.sort { $0.name < $1.name }
    }

    mutating func remove(stop: Stop) {
        if let index = stops.index(of: stop) {
            stops.remove(at: index)
        }

        stops.sort { $0.name < $1.name }
    }
}

extension Favorite {

    static var all: [Favorite] {
        if let json = UserDefaults.standard.array(forKey: Constants.UserDefaults.favorites.rawValue) as? [JSON] {
            return json.map { Favorite.fromJson($0) }
        }

        return []
    }

    static var current: Favorite? {
        if let json = UserDefaults.standard.dictionary(forKey: Constants.UserDefaults.currentFavorite.rawValue) {
            return Favorite.fromJson(json)
        }

        return nil
    }

    static func removeCurrent() {
        UserDefaults.standard.removeObject(key: .currentFavorite)
        StopDataHandler.shared.currentFavorite = nil
    }

    func saveCurrent() {
        UserDefaults.standard.set(toJson(), key: .currentFavorite)
        StopDataHandler.shared.currentFavorite = self
    }

    func save() {
        let allFavorites = StopDataHandler.shared.favorites
        var favoritesToSave = [Favorite]()

        if allFavorites.contains(self) {
            allFavorites.forEach { favorite in
                self == favorite ? favoritesToSave.append(self) : favoritesToSave.append(favorite)
            }
        } else {
            favoritesToSave.append(contentsOf: allFavorites + [self])
        }

        favoritesToSave.save()
        StopDataHandler.shared.favorites = favoritesToSave
    }

    func remove() {
        var favorites = StopDataHandler.shared.favorites
        if let index = favorites.index(of: self) {
            favorites.remove(at: index)
        }

        favorites.save()
        StopDataHandler.shared.favorites = favorites
    }
}

extension Favorite {

    static var defaultFavorite: Favorite {
        let json = [
            [
                "id": "9021014001760000",
                "lat": "57.706945",
                "lon": "11.967843",
                "name": "Brunnsparken"
            ],
            [
                "id": "9021014001950000",
                "lat": "57.707898",
                "lon": "11.973740",
                "name": "Centralstationen"
            ]
        ]

        var stops = [Stop]()
        json.forEach { json in
            do { stops.append(try Mapper<Stop>().map(JSON: json)) } catch {}
        }

        return Favorite(name: "Centrum", stops: stops)
    }
}

extension Favorite: Equatable {

    static func ==(lhs: Favorite, rhs: Favorite) -> Bool {
        return lhs.id == rhs.id
    }
}
