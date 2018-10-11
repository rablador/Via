import UIKit

enum Animation {

    enum Alpha: Double {

        case transparent = 0
        case faded = 0.3
        case opaque = 1
    }

    enum Duration: Double {

        case now = 0
        case fast = 0.1
        case fade = 0.2
        case slide = 0.3
        case medium = 0.4
        case long = 0.6
    }

    enum Direction {

        case inwards
        case outwards
    }
}
