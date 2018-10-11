import UIKit

struct SearchResultCellModel {

    let stop: Stop

    var name: String { return stop.name }
    var city: String { return stop.city }
    var icon: UIImage { return stop.type == .stop ? #imageLiteral(resourceName: "icon_stop_short") : #imageLiteral(resourceName: "icon_address") }
}
