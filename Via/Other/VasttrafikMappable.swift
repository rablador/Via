import ObjectMapper

public protocol VasttrafikArrayMappable {

    associatedtype T
    static func jsonToArray(_ json: JSON) -> [T]
}

public protocol VasttrafikObjectMappable {

    associatedtype T
    static func jsonToObject(_ json: JSON) -> T?
}
