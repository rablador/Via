import UIKit

struct LegCellModel {

    let leg: Leg

    var name: String { return leg.name }
    var direction: String { return leg.direction }
    var fgColor: UIColor { return leg.fgColor }
    var bgColor: UIColor { return leg.bgColor }
    var accessibility: VasttrafikEnum.Accessibility { return leg.accessibility }

    var startTime: String { return leg.origin.time }
    var startOrigTime: String { return leg.origin.origTime }
    var startTimeLeft: String {
        let startTimeLeft = leg.origin.timeLeft
        return startTimeLeft > 0 ? String(startTimeLeft) : "Nu"
    }
    var startStop: String { return leg.origin.name }
    var startTrack: String { return leg.origin.track }

    var stopTime: String { return leg.destination.time }
    var stopOrigTime: String { return leg.destination.origTime }
    var stopTimeLeft: String {
        let stopTimeLeft = leg.destination.timeLeft
        return stopTimeLeft > 0 ? String(stopTimeLeft) : "Nu"
    }
    var stopStop: String { return leg.destination.name }
    var stopTrack: String { return leg.destination.track }
}
