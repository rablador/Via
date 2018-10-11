import UIKit

struct JourneyDetailStopCellModel {

    let stop: JourneyDetailStop

    var stopTime: String? { return stop.arrTime ?? stop.depTime }
    var stopOrigTime: String? { return stop.arrOrigTime }
    var stopTimeLeft: String? {
        if let stopTimeLeft = stop.arrTimeLeft {
            return stopTimeLeft > 0 ? String(stopTimeLeft) : "Nu"
        } else {
            return nil
        }
    }
    var stopStop: String { return stop.name }
    var stopTrack: String { return stop.track }
}
