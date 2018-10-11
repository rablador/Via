import Foundation

struct Time {

    let timeShift: Constants.TimeShift

    var departureDate: Date {
        let timeShiftedDate = Date().inFuture(mins: timeShift.rawValue)

        if timeShift.rawValue > 60 {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: timeShiftedDate)
            return Calendar.current.date(from: components) ?? timeShiftedDate
        } else {
            return timeShiftedDate
        }
    }
}

extension Time {

    static var current: Time {
        let timeShiftValue = UserDefaults.standard.integer(forKey: Constants.UserDefaults.currentTime.rawValue)
        return Time(timeShift: Constants.TimeShift(rawValue: timeShiftValue) ?? .now)
    }

    static var isFuture: Bool {
        return !StopDataHandler.shared.currentCommute.isNil
    }

    static func removeCurrent() {
        UserDefaults.standard.removeObject(key: .currentTime)
        StopDataHandler.shared.currentTime = Time(timeShift: .now)
    }

    func saveCurrent() {
        UserDefaults.standard.set(timeShift.rawValue, key: .currentTime)
        StopDataHandler.shared.currentTime = self
    }
}

extension Time: Equatable {

    static func ==(lhs: Time, rhs: Time) -> Bool {
        return lhs.timeShift == rhs.timeShift
    }
}
