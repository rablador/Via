import UIKit
import ObjectMapper
import CoreLocation

struct Departure: ImmutableMappable, DepartureItem {

    var filterId: String { return name + direction + stopId }
    var uniqueId: String { return journeyId }

    let journeyId: String
    let journeyDetailRef: String

    private let _stop: String
    var stop: String { return _stop.components(separatedBy: ",")[0] }

    var city: String {
        let components = _stop.components(separatedBy: ",")

        if (components.count > 1) {
            return components[1]
        } else {
            return ""
        }
    }

    let stopId: String

    private let _rtTrack: String?
    private let _track: String
    var track: String { return _rtTrack ?? _track }

    let name: String
    let direction: String
    let type: VasttrafikEnum.DepartureType
    let accessibility: VasttrafikEnum.Accessibility

    private let _night: Bool?
    var night: Bool { return _night ?? false }

    let bgColor: UIColor
    let fgColor: UIColor

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

        bgColor = try map.value("bgColor", using: VasttrafikTransform.color())
        fgColor = try map.value("fgColor", using: VasttrafikTransform.color())

        _stop = try map.value("stop")
        stopId = try map.value("stopid", using: VasttrafikTransform.stopId())
        _rtTrack = try? map.value("rtTrack")
        _track = try map.value("track")

        name = try map.value("sname")
        direction = try map.value("direction", using: VasttrafikTransform.direction())
        type = try map.value("type", using: VasttrafikTransform.departureType())
        accessibility = try map.value("accessibility", using: VasttrafikTransform.accessibility())
        _night = try? map.value("night", using: VasttrafikTransform.toBool())

        journeyId = try map.value("journeyid")
        journeyDetailRef = try map.value("JourneyDetailRef.ref", using: VasttrafikTransform.journeyDetail())

        if DateFormatter.dateTimeFormatter.date(from: "\(_date) \(origTime)").isNil { throw DebugError("Could not get date from date string.") }
    }

    mutating func mapping(map: Map) {}
}

extension Departure: VasttrafikArrayMappable {

    static func jsonToArray(_ json: JSON) -> [Departure] {
        var departures = [Departure]()

        guard let departureBoard = json["DepartureBoard"] as? JSON else { return departures }

        if let departure = departureBoard["Departure"] as? [JSON] {
            departure.forEach { json in
                do { departures.append(try Mapper<Departure>().map(JSON: json)) } catch {}
            }
        } else if let departure = departureBoard["Departure"] as? JSON {
            do { departures.append(try Mapper<Departure>().map(JSON: departure)) } catch {}
        }

        return departures
    }
}

extension Departure: Equatable {

    static func ==(lhs: Departure, rhs: Departure) -> Bool {
        return lhs.filterId == rhs.filterId
    }
}
