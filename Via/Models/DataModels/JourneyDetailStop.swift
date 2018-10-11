import UIKit
import ObjectMapper
import CoreLocation

struct JourneyDetailStop: ImmutableMappable {

    private let _rtTrack: String?
    private let _track: String
    var track: String { return _rtTrack ?? _track }

    let routeIdx: String
    let id: String

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

    private let _depTime: String?
    private let _rtDepTime: String?
    private let _depDate: String?
    private let _rtDepDate: String?

    private let _arrTime: String?
    private let _rtArrTime: String?
    private let _arrDate: String?
    private let _rtArrDate: String?

    var depOrigTime: String? { return _depTime }
    var depTime: String? { return _rtDepTime ?? _depTime }
    var depTimeLeft: Int? {
        if let depDate = depDate { return Int(depDate.timeIntervalSinceNow / 60) }
        return nil
    }

    var arrOrigTime: String? { return _arrTime! }
    var arrTime: String? { return _rtArrTime ?? _arrTime }
    var arrTimeLeft: Int? {
        if let arrDate = arrDate { return Int(arrDate.timeIntervalSinceNow / 60) }
        return nil
    }

    var depDate: Date? {
        if let rtDepTime = _rtDepTime, let rtDepDate = _rtDepDate {
            return DateFormatter.dateTimeFormatter.date(from: "\(rtDepDate) \(rtDepTime)")!
        } else if let depTime = _depTime, let depDate = _depDate {
            return DateFormatter.dateTimeFormatter.date(from: "\(depDate) \(depTime)")!
        }

        return nil
    }

    var arrDate: Date? {
        if let rtArrTime = _rtArrTime, let rtArrDate = _rtArrDate {
            return DateFormatter.dateTimeFormatter.date(from: "\(rtArrDate) \(rtArrTime)")!
        } else if let arrTime = _arrTime, let arrDate = _arrDate {
            return DateFormatter.dateTimeFormatter.date(from: "\(arrDate) \(arrTime)")!
        }

        return nil
    }

    init(map: Map) throws {
        _depTime = try? map.value("depTime", using: VasttrafikTransform.time())
        _rtDepTime = try? map.value("rtDepTime", using: VasttrafikTransform.time())
        _depDate = try? map.value("depDate")
        _rtDepDate = try? map.value("rtDepDate")

        _arrTime = try? map.value("arrTime", using: VasttrafikTransform.time())
        _rtArrTime = try? map.value("rtArrTime", using: VasttrafikTransform.time())
        _arrDate = try? map.value("arrDate")
        _rtArrDate = try? map.value("rtArrDate")

        _rtTrack = try? map.value("rtTrack")
        _track = try map.value("track")

        routeIdx = try map.value("routeIdx")
        id = try map.value("id", using: VasttrafikTransform.stopId())
        _name = try map.value("name")

        if let arrTime = _arrTime, let arrDate = _arrDate {
            if DateFormatter.dateTimeFormatter.date(from: "\(arrDate) \(arrTime)").isNil { throw DebugError("Could not get date from date string.") }
        }
    }

    mutating func mapping(map: Map) {}
}

extension JourneyDetailStop: VasttrafikArrayMappable {

    static func jsonToArray(_ json: JSON) -> [JourneyDetailStop] {
        var stops = [JourneyDetailStop]()

        if let stop = json["Stop"] as? [JSON] {
            stop.forEach { json in
                do { stops.append(try Mapper<JourneyDetailStop>().map(JSON: json)) } catch {}
            }
        } else if let stop = json["Stop"] as? JSON {
            do { stops.append(try Mapper<JourneyDetailStop>().map(JSON: stop)) } catch {}
        }

        return stops.sorted { Int($0.routeIdx)! < Int($1.routeIdx)! }
    }
}

extension JourneyDetailStop: Equatable {

    static func ==(lhs: JourneyDetailStop, rhs: JourneyDetailStop) -> Bool {
        return lhs.id == rhs.id
    }
}
