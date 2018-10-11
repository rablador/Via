import UIKit

protocol DepartureCellModelItem {

    var legs: [Leg]? { get }
    var origin: String { get }
    var time: String { get }
    var timeNext: String? { get }
    var track: String { get }
    var origTime: String { get }
    var timeLeft: String { get }
    var timeLeftNext: String? { get }
    var name: String { get }
    var direction: String { get }
    var bgColor: UIColor { get }
    var fgColor: UIColor { get }
    var accessibility: VasttrafikEnum.Accessibility { get }
}
