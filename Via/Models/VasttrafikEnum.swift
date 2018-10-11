import UIKit

enum VasttrafikEnum {

    enum Accessibility: String {

        case none = "none"
        case lowFloor = "lowFloor"
        case wheelChair = "wheelChair"

        static let values: [Accessibility] = [.none, .lowFloor, .wheelChair]
    }

    enum DepartureType: String {

        case boat = "BOAT"
        case bus = "BUS"
        case tram = "TRAM"

        static let values: [DepartureType] = [.boat, .bus, .tram]
    }

    enum StopType: String {

        case address = "ADR"
        case stop = "ST"

        static let values: [StopType] = [.address, .stop]
    }

    enum NoteSeverity: String {

        case low = "low"
        case normal = "normal"
        case high = "high"

        static let values: [NoteSeverity] = [.low, .normal, .high]
    }

    static func accesibilityIcon(from accessibility: Accessibility) -> UIImage? {
        switch accessibility {
        case .lowFloor:
            return nil
        case .wheelChair:
            return #imageLiteral(resourceName: "icon_wheelchair")
        default:
            return nil
        }
    }
}
