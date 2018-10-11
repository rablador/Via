import UIKit
import ObjectMapper
import CoreLocation

struct JourneyDetail: ImmutableMappable {

    let id: String
    var stops = [JourneyDetailStop]()

    init(map: Map) throws {
        id = try map.value("JourneyId.id")
    }

    mutating func mapping(map: Map) {}
}

extension JourneyDetail: VasttrafikObjectMappable {

    static func jsonToObject(_ json: JSON) -> JourneyDetail? {
        return journeyDetail(from: json)
    }

    static private func journeyDetail(from json: JSON) -> JourneyDetail? {
        do {
            if let journeyDetailJson = json["JourneyDetail"] as? JSON {
                var journeyDetail = try Mapper<JourneyDetail>().map(JSON: journeyDetailJson)
                journeyDetail.stops = JourneyDetailStop.jsonToArray(journeyDetailJson)

                return journeyDetail
            }
        } catch {}

        return nil
    }
}
