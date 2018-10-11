import Foundation

extension Date {

    func inFuture(mins: Int) -> Date {
        return addingTimeInterval(Double(mins) * 60)
    }
}

extension DateFormatter {

    static let TIME_FORMAT = "HH.mm"
    static let DATE_FORMAT = "yyyy-MM-dd"
    static let DATE_TIME_FORMAT = "yyyy-MM-dd HH.mm"
    static let TIME_VIEW_FORMAT = "E d MMM HH.mm"
    static let WEEK_TIME_FORMAT = "E HH.mm"

    static var timeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = TIME_FORMAT
        return dateFormatter
    }

    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_FORMAT
        return dateFormatter
    }

    static var dateTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DATE_TIME_FORMAT
        return dateFormatter
    }

    static var timeViewFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "sv_SE")
        dateFormatter.dateFormat = TIME_VIEW_FORMAT
        return dateFormatter
    }

    static var weekTimeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "sv_SE")
        dateFormatter.dateFormat = WEEK_TIME_FORMAT
        return dateFormatter
    }
}
