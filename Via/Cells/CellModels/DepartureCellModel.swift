import UIKit

struct DepartureCellModel: DepartureCellModelItem {

    var departure: Departure { return departures.first! }
    var departureNext: Departure? { return (departures.count > 1) ? departures[1] : nil }

    var time: String { return currentDeparture.time }
    var timeNext: String? { return departureNext?.time }
    var origTime: String { return currentDeparture.origTime }
    var timeLeft: String {
        let timeLeft = currentDeparture.timeLeft
        return timeLeft > 0 ? String(timeLeft) : "Nu"
    }
    var timeLeftNext: String? {
        if let timeLeft = departureNext?.timeLeft {
            return timeLeft > 0 ? String(timeLeft) : "Nu"
        }
        return nil
    }

    var legs: [Leg]? { return nil }
    var origin: String { return currentDeparture.stop }
    var name: String { return currentDeparture.name }
    var direction: String { return currentDeparture.direction }
    var fgColor: UIColor { return currentDeparture.fgColor }
    var bgColor: UIColor { return currentDeparture.bgColor }
    var track: String { return currentDeparture.track }
    var night: Bool { return currentDeparture.night }
    var accessibility: VasttrafikEnum.Accessibility { return currentDeparture.accessibility }
    var journeyId: String { return currentDeparture.journeyId }
    var journeyDetailRef: String { return currentDeparture.journeyDetailRef }

    private (set) var departures: [Departure]
    private (set) var currentDeparture: Departure

    init(departures: [Departure]) {
        self.departures = departures
        currentDeparture = departures.first!
    }

    mutating func setCurrentDeparture(departure: Departure?) {
        currentDeparture = departure ?? self.departure
    }
}

extension DepartureCellModel: Equatable {

    static func ==(lhs: DepartureCellModel, rhs: DepartureCellModel) -> Bool {
        return (lhs.departure.filterId == rhs.departure.filterId) ||
               (lhs.departure.filterId == rhs.departureNext?.filterId) ||
               (lhs.departureNext?.filterId == rhs.departure.filterId) ||
               (lhs.departureNext?.filterId == rhs.departureNext?.filterId)
    }
}
