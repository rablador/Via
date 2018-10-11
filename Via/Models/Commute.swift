import Foundation
import ObjectMapper

struct Commute {

    let id: String
    
    var date: Date
    var isDeparture: Bool
    var fromStop: Stop?
    var toStops: [Stop]?

    init(id: String = String.random(), date: Date, isDeparture: Bool, fromStop: Stop?, toStops: [Stop]?) {
        self.id = id
        self.date = date
        self.isDeparture = isDeparture
        self.fromStop = fromStop
        self.toStops = toStops
    }

    func toJson() -> JSON {
        var json: [String: Any] = [
            "id": id,
            "date": date,
            "isDeparture": isDeparture
        ]

        if let fromStop = fromStop { json["fromStop"] = fromStop.toJSON() }
        if let toStops = toStops { json["toStops"] = toStops.map { $0.toJSON() }}

        return json
    }

    private static func fromJson(_ json: JSON) -> Commute {
        let id = json["id"] as! String
        let date = json["date"] as! Date
        let isDeparture = json["isDeparture"] as! Bool

        var commute = Commute(
            id: id,
            date: date,
            isDeparture: isDeparture,
            fromStop: nil,
            toStops: nil
        )

        if let fromStopJson = json["fromStop"] as? JSON { commute.fromStop = Stop.userDefaultsJsonToStop(fromStopJson) }
        if let toStopsJson = json["toStops"] as? [JSON] { commute.toStops = Stop.userDefaultsJsonToStops(toStopsJson) }

        return commute
    }
}

extension Commute {

    static var all: [Commute] {
        if let json = UserDefaults.standard.array(forKey: Constants.UserDefaults.commutes.rawValue) as? [JSON] {
            return json.map { Commute.fromJson($0) }
        }

        return []
    }

    static var current: Commute? {
        if let json = UserDefaults.standard.dictionary(forKey: Constants.UserDefaults.currentCommute.rawValue) {
            return Commute.fromJson(json)
        }

        return nil
    }

    static func removeCurrent(_ silent: Bool = false) {
        UserDefaults.standard.removeObject(key: .currentCommute)
        if !silent { StopDataHandler.shared.currentCommute = nil }

        PublishSubjects.shared.currentCommuteUpdatedSubject.onNext(nil)
    }

    func saveCurrent(_ silent: Bool = false) {
        UserDefaults.standard.set(toJson(), key: .currentCommute)
        if !silent { StopDataHandler.shared.currentCommute = self }

        PublishSubjects.shared.currentCommuteUpdatedSubject.onNext(self)
    }

    func save() {
        let allCommutes = StopDataHandler.shared.commutes
        var commutesToSave = [Commute]()

        if allCommutes.contains(self) {
            allCommutes.forEach { commute in
                self == commute ? commutesToSave.append(self) : commutesToSave.append(commute)
            }
        } else {
            commutesToSave.append(contentsOf: allCommutes + [self])
        }

        commutesToSave.save()
        StopDataHandler.shared.commutes = commutesToSave
    }

    func remove() {
        var commutes = StopDataHandler.shared.commutes
        if let index = commutes.index(of: self) {
            commutes.remove(at: index)
        }

        commutes.save()
        StopDataHandler.shared.commutes = commutes
    }
}

extension Commute: Equatable {

    static func ==(lhs: Commute, rhs: Commute) -> Bool {
        return lhs.id == rhs.id
    }
}
