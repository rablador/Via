import UIKit

@IBDesignable
class TransferEndView: XibView {

    @IBOutlet weak var time: UILabel!

    func setup(leg: Leg) {
        time.text = leg.destination.time
    }
}
