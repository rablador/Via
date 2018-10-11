import Moya
import CoreLocation

enum VasttrafikTarget {

    case accessToken()
    case nearbyStops(location: CLLocation)
    case departures(date: Date, timeSpan: Int, origin: Stop)
    case trips(date: Date, origin: Stop, destination: Stop, isDeparture: Bool)
    case searchStops(searchString: String)
    case journeyDetail(ref: String)
}

extension VasttrafikTarget: TargetType {

    var apiSecret: String { return "UG1PaE9zRmc5Sjl1Yk5nZ3lFbTVpWVlxUHZnYTpfbFRiVkRLWm9Ia2hRdW0yeGh6MGdaRktmdzBh" }

    var baseURL: URL {
        switch self {
        case .accessToken:
            return URL(string: "https://api.vasttrafik.se/")!
        default:
            return URL(string: "https://api.vasttrafik.se/bin/rest.exe/v2/")!
        }
    }

    var path: String {
        switch self {
        case .accessToken:
            return "token"
        case .nearbyStops:
            return "location.nearbystops"
        case .departures:
            return "departureBoard"
        case .trips:
            return "trip"
        case .searchStops:
            return "location.name"
        case .journeyDetail:
            return "journeyDetail"
        }
    }

    var method: Moya.Method {
        switch self {
        case .accessToken:
            return .post
        default:
            return .get
        }
    }

    var headers: SDICT? {
        switch self {
        case .accessToken:
            return ["Authorization": "Basic \(apiSecret)"]
        default:
            let accessToken = AccessToken.load()
            return ["Authorization": "Bearer \(accessToken)"]
        }
    }

    var parameters: JSON {
        switch self {
        case .accessToken:
            return [
                "scope": UserDefaults.standard.string(forKey: Constants.UserDefaults.authScope.rawValue) ?? "",
                "grant_type": "client_credentials",
                "format": "json"
            ]
        case .nearbyStops(let location):
            return [
                "originCoordLat": String(location.coordinate.latitude),
                "originCoordLong": String(location.coordinate.longitude),
                "maxNo": "50",
                "format": "json"
            ]
        case .departures(let date, let timeSpan, let origin):
            return [
                "date": DateFormatter.dateFormatter.string(from: date),
                "time": DateFormatter.timeFormatter.string(from: date),
                "id": origin.id,
                "timeSpan": String(timeSpan),
                "maxDeparturesPerLine": "2",
                "useLDTrain": "0",
                "useRegTrain": "0",
                "excludeDR": "0",
                "format": "json"
            ]
        case .trips(let date, let origin, let destination, let isDeparture):
            return [
                "date": DateFormatter.dateFormatter.string(from: date),
                "time": DateFormatter.timeFormatter.string(from: date),
                "originId": origin.id,
                "destId": destination.id,
                "searchForArrival": !isDeparture ? 1 : 0,
                "useVas": "0",
                "useLDTrain": "0",
                "useRegTrain": "0",
                "excludeDR": "0",
                "originWalk": "0",
                "destWalk": "0",
                "disregardDefaultChangeMargin": "1",
                "format": "json"
            ]
        case .searchStops(let searchString):
            return [
                "input": searchString,
                "format": "json"
            ]
        case .journeyDetail(let ref):
            return [
                "ref": ref,
                "format": "json"
            ]
        }
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }

    var sampleData: Data {
        switch self {
        case .accessToken:
            return "{}".data(using: .utf8)!
        case .nearbyStops:
            return "{}".data(using: .utf8)!
        case .departures:
            return "{}".data(using: .utf8)!
        case .trips:
            return "{}".data(using: .utf8)!
        case .searchStops:
            return "{}".data(using: .utf8)!
        case .journeyDetail:
            return "{}".data(using: .utf8)!
        }
    }

    var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
}
