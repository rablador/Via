import UIKit
import ObjectMapper

struct Leg: ImmutableMappable {

    let journeyId: String
    let journeyDetailRef: String

    var name: String
    let direction: String
    let type: VasttrafikEnum.DepartureType
    let accessibility: VasttrafikEnum.Accessibility

    let bgColor: UIColor
    let fgColor: UIColor

    private let _night: Bool?
    var night: Bool { return _night ?? false }

    private let _cancelled: Bool?
    var cancelled: Bool { return _cancelled ?? false }

    private let _notes: [Note]?
    var notes: [Note]? { return _notes?.filterDuplicatesOnAttribute { $0.text == $1.text } }

    let origin: Origin
    let destination: Destination

    init(map: Map) throws {
        bgColor = try map.value("bgColor", using: VasttrafikTransform.color())
        fgColor = try map.value("fgColor", using: VasttrafikTransform.color())

        name = try map.value("sname")
        direction = try map.value("direction", using: VasttrafikTransform.direction())
        type = try map.value("type", using: VasttrafikTransform.departureType())
        accessibility = try map.value("accessibility", using: VasttrafikTransform.accessibility())

        _night = try? map.value("night", using: VasttrafikTransform.toBool())
        _cancelled = try? map.value("cancelled", using: VasttrafikTransform.toBool())

        journeyId = try map.value("id")
        journeyDetailRef = try map.value("JourneyDetailRef.ref", using: VasttrafikTransform.journeyDetail())

        _notes = try? map.value("Note")
        origin = try map.value("Origin")
        destination = try map.value("Destination")
    }

    mutating func mapping(map: Map) {}
}

extension Leg: VasttrafikArrayMappable {

    static func jsonToArray(_ json: JSON) -> [Leg] {
        var legs = [Leg]()

        if let leg = json["Leg"] as? [JSON] {
            leg.forEach { json in
                do { legs.append(try Mapper<Leg>().map(JSON: json)) } catch {}
            }
        } else if let leg = json["Leg"] as? JSON {
            do { legs.append(try Mapper<Leg>().map(JSON: leg)) } catch {}
        }

        return legs
    }
}
