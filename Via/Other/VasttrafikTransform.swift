import UIKit
import ObjectMapper

struct VasttrafikTransform {

    static func color() -> TransformOf<UIColor, String> {
        return TransformOf<UIColor, String>(fromJSON: { (value: String?) -> UIColor? in
            if let color = value {
                return UIColor(hexString: color)
            }
            return nil
        }, toJSON: { (value: UIColor?) -> String? in
            if let color = value {
                return color.toHexString()
            }
            return nil
        })
    }

    static func direction() -> TransformOf<String, String> {
        return TransformOf<String, String>(fromJSON: { (value: String?) -> String? in
            if let direction = value {
                return direction.components(separatedBy: ",")[0].components(separatedBy: " via")[0]
            }
            return nil
        }, toJSON: { (value: String?) -> String? in return value })
    }

    static func time() -> TransformOf<String, String> {
        return TransformOf<String, String>(fromJSON: { (value: String?) -> String? in
            if let time = value {
                return time.replacingOccurrences(of: ":", with: ".")
            }
            return nil
        }, toJSON: { (value: String?) -> String? in return value })
    }

    static func accessibility() -> TransformOf<VasttrafikEnum.Accessibility, String> {
        return TransformOf<VasttrafikEnum.Accessibility, String>(fromJSON: { (value: String?) -> VasttrafikEnum.Accessibility? in
            if let accessibility = value {
                for value in VasttrafikEnum.Accessibility.values where value.rawValue == accessibility {
                    return value
                }
            }
            return VasttrafikEnum.Accessibility.none
        }, toJSON: { (value: VasttrafikEnum.Accessibility?) -> String? in
            if let accessibility = value {
                return accessibility.rawValue
            }
            return nil
        })
    }

    static func journeyDetail() -> TransformOf<String, String> {
        return TransformOf<String, String>(fromJSON: { (value: String?) -> String? in
            if let ref = value {
                return ref.components(separatedBy: "ref=").last?.removingPercentEncoding
            }
            return nil
        }, toJSON: { (value: String?) -> String? in return value })
    }

    static func departureType() -> TransformOf<VasttrafikEnum.DepartureType, String> {
        return TransformOf<VasttrafikEnum.DepartureType, String>(fromJSON: { (value: String?) -> VasttrafikEnum.DepartureType? in
            if let type = value {
                for value in VasttrafikEnum.DepartureType.values where value.rawValue == type {
                    return value
                }
            }
            return nil
        }, toJSON: { (value: VasttrafikEnum.DepartureType?) -> String? in
            if let type = value {
                return type.rawValue
            }
            return nil
        })
    }

    static func stopType() -> TransformOf<VasttrafikEnum.StopType, String> {
        return TransformOf<VasttrafikEnum.StopType, String>(fromJSON: { (value: String?) -> VasttrafikEnum.StopType? in
            if let type = value {
                for value in VasttrafikEnum.StopType.values where value.rawValue == type {
                    return value
                }
            }
            return nil
        }, toJSON: { (value: VasttrafikEnum.StopType?) -> String? in
            if let type = value {
                return type.rawValue
            }
            return nil
        })
    }

    static func noteSeverity() -> TransformOf<VasttrafikEnum.NoteSeverity, String> {
        return TransformOf<VasttrafikEnum.NoteSeverity, String>(fromJSON: { (value: String?) -> VasttrafikEnum.NoteSeverity? in
            if let type = value {
                for value in VasttrafikEnum.NoteSeverity.values where value.rawValue == type {
                    return value
                }
            }
            return nil
        }, toJSON: { (value: VasttrafikEnum.NoteSeverity?) -> String? in
            if let type = value {
                return type.rawValue
            }
            return nil
        })
    }

    static func stopId() -> TransformOf<String, String> {
        return TransformOf<String, String>(fromJSON: { (value: String?) -> String? in
            if let stopId = value {
                return stopId[...stopId.index(stopId.endIndex, offsetBy: -3)] + "000"
            }
            return nil
        }, toJSON: { (value: String?) -> String? in return value })
    }

    static func toDouble() -> TransformOf<Double, String> {
        return TransformOf<Double, String>(fromJSON: { (value: String?) -> Double? in
            if let value = value {
                return Double(value)
            }
            return nil
        }, toJSON: { (value: Double?) -> String? in
            if let value = value {
                return String(value)
            }
            return nil
        })
    }

    static func toInt() -> TransformOf<Int, String> {
        return TransformOf<Int, String>(fromJSON: { (value: String?) -> Int? in
            if let value = value {
                return Int(value)
            }
            return nil
        }, toJSON: { (value: Int?) -> String? in
            if let value = value {
                return String(value)
            }
            return nil
        })
    }

    static func toBool() -> TransformOf<Bool, String> {
        return TransformOf<Bool, String>(fromJSON: { (value: String?) -> Bool? in
            if let value = value {
                return Bool(value)
            }
            return nil
        }, toJSON: { (value: Bool?) -> String? in
            if let value = value {
                return String(value)
            }
            return nil
        })
    }
}

extension VasttrafikTransform {

    static func filterStopId() -> TransformOf<String, String> {
        return TransformOf<String, String>(fromJSON: { (value: String?) -> String? in
            if let stopId = value, (stopId == "address") || (stopId.suffix(3) == "000") {
                return stopId
            } else if value == nil {
                return "address"
            }
            return nil
        }, toJSON: { (value: String?) -> String? in return value })
    }
}
