import UIKit

struct TripCellModel: DepartureCellModelItem {

    var trip: Trip { return trips.first! }
    var tripNext: Trip? { return (trips.count > 1) ? trips[1] : nil }

    var time: String { return legs!.first!.origin.time }
    var timeNext: String? { return tripNext?.legs.first?.origin.time }
    var origTime: String { return legs!.first!.origin.origTime }
    var timeLeft: String {
        let timeLeft = legs!.first!.origin.timeLeft
        return timeLeft > 0 ? String(timeLeft) : "Nu"
    }
    var timeLeftNext: String? {
        if let timeLeft = tripNext?.legs.first?.origin.timeLeft {
            return timeLeft > 0 ? String(timeLeft) : "Nu"
        }
        return nil
    }

    var legs: [Leg]? { return currentTrip.legs }
    var origin: String { return currentTrip.legs.first!.origin.name }
    var name: String { return currentTrip.legs.first!.name }
    var direction: String { return currentTrip.legs.first!.direction }
    var fgColor: UIColor { return currentTrip.legs.first!.fgColor }
    var bgColor: UIColor { return currentTrip.legs.first!.bgColor }
    var transfers: [Leg] { return Array(currentTrip.legs.dropFirst()) }

    var departureTime: String { return DateFormatter.timeFormatter.string(from: currentTrip.legs.first!.origin.date) }
    var arrivalTime: String { return DateFormatter.timeFormatter.string(from: currentTrip.legs.last!.destination.date) }
    var track: String { return currentTrip.legs.first!.origin.track }
    var accessibility: VasttrafikEnum.Accessibility { return currentTrip.legs.first!.accessibility }
    var night: Bool { return currentTrip.legs.first!.night }
    var notes: [Note]? { return currentTrip.legs.first!.notes }

    private (set) var trips: [Trip]
    private (set) var currentTrip: Trip

    init(trips: [Trip]) {
        self.trips = trips
        currentTrip = trips.first!
    }

    mutating func setCurrentTrip(trip: Trip?) {
        currentTrip = trip ?? self.trip
    }
}

extension TripCellModel: Equatable {

    static func ==(lhs: TripCellModel, rhs: TripCellModel) -> Bool {
        return (lhs.trip.filterId == rhs.trip.filterId) ||
            (lhs.trip.filterId == rhs.tripNext?.filterId) ||
            (lhs.tripNext?.filterId == rhs.trip.filterId) ||
            (lhs.tripNext?.filterId == rhs.tripNext?.filterId)
    }
}
