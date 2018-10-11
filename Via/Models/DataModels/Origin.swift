import UIKit
import ObjectMapper

struct Origin: ImmutableMappable {

    private let _rtTrack: String?
    private let _track: String
    var track: String { return _rtTrack ?? _track }

    let id: String
    let type: VasttrafikEnum.StopType

    private let _name: String
    var name: String { return _name.components(separatedBy: ",")[0] }

    var city: String {
        let components = _name.components(separatedBy: ",")

        if (components.count > 1) {
            return components[1]
        } else {
            return ""
        }
    }

    private let _cancelled: Bool?
    var cancelled: Bool { return _cancelled ?? false }

    let origTime: String
    private let _rtTime: String?
    private let _date: String
    private let _rtDate: String?

    var time: String { return _rtTime ?? origTime }
    var timeLeft: Int { return Int(date.timeIntervalSinceNow / 60) }

    var date: Date {
        if let rtTime = _rtTime, let rtDate = _rtDate {
            return DateFormatter.dateTimeFormatter.date(from: "\(rtDate) \(rtTime)")!
        } else {
            return DateFormatter.dateTimeFormatter.date(from: "\(_date) \(origTime)")!
        }
    }

    var timeDiff: Int {
        let date = DateFormatter.dateTimeFormatter.date(from: "\(_date) \(origTime)")!
        return Int(self.date.timeIntervalSince(date) / 60)
    }

    init(map: Map) throws {
        origTime = try map.value("time", using: VasttrafikTransform.time())
        _rtTime = try? map.value("rtTime", using: VasttrafikTransform.time())
        _date = try map.value("date")
        _rtDate = try? map.value("rtDate")

        _rtTrack = try? map.value("rtTrack")
        _track = try map.value("track")

        id = try map.value("id", using: VasttrafikTransform.stopId())
        _name = try map.value("name")
        type = try map.value("type", using: VasttrafikTransform.stopType())
        _cancelled = try? map.value("cancelled", using: VasttrafikTransform.toBool())

        if DateFormatter.dateTimeFormatter.date(from: "\(_date) \(origTime)").isNil { throw DebugError("Could not get date from date string.") }
    }

    mutating func mapping(map: Map) {}
}

extension Origin: VasttrafikObjectMappable {

    static func jsonToObject(_ json: JSON) -> Origin? {
        return Mapper<Origin>().map(JSON: json)
    }
}
