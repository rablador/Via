import ObjectMapper

struct AccessToken: ImmutableMappable {

    let token: String

    init(map: Map) throws {
        token = try map.value("access_token")
    }

    mutating func mapping(map: Map) {}
}

extension AccessToken: VasttrafikObjectMappable {
    
    static func jsonToObject(_ json: JSON) -> AccessToken? {
        return Mapper<AccessToken>().map(JSON: json)
    }
}

extension AccessToken {

    func save() {
        UserDefaults.standard.set(token, key: .accessToken).synchronize()
    }

    static func load() -> String {
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.accessToken.rawValue) ?? ""
    }
}
