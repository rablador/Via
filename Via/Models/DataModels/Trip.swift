import UIKit
import ObjectMapper

struct Trip: ImmutableMappable, DepartureItem {

    var filterId: String { return legs.map { $0.name + $0.direction + $0.origin.id }.joined() }
    var uniqueId: String { return legs.map { $0.journeyId }.joined() }

    private let _type: VasttrafikEnum.DepartureType?
    private let _valid: Bool?
    var valid: Bool { return _type.isNil && (_valid.isNil || _valid!) }

    var legs = [Leg]()

    init(map: Map) throws {
        _type = try? map.value("type", using: VasttrafikTransform.departureType())
        _valid = try? map.value("valid", using: VasttrafikTransform.toBool())
    }

    mutating func mapping(map: Map) {}
}

extension Trip: VasttrafikArrayMappable {

    static func jsonToArray(_ json: JSON) -> [Trip] {
        var trips = [Trip]()

        guard let tripList = json["TripList"] as? JSON else { return trips }

        if let trip = tripList["Trip"] as? [JSON] {
            trip.forEach { json in
                if let trip = Trip.trip(from: json) { trips.append(trip) }
            }
        } else if let trip = tripList["Trip"] as? JSON {
            if let trip = Trip.trip(from: trip) { trips.append(trip) }
        }

        return trips
    }

    static private func trip(from json: JSON) -> Trip? {
        do {
            var trip = try Mapper<Trip>().map(JSON: json)

            if trip.valid {
                let legs = Leg.jsonToArray(json)
                trip.legs = legs
                
                return trip
            }
        } catch {}

        return nil
    }
}
