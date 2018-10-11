import Foundation

struct TimeCellModel {

    let time: Time

    var title: String {
        if time.timeShift.rawValue > 60 {
            return "\(Calendar.current.component(.hour, from: time.departureDate)):00"
        } else if time.timeShift == .now {
            return "Nu"
        } else {
            return "+\(time.timeShift.rawValue) min"
        }
    }
}
