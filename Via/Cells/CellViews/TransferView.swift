import UIKit

@IBDesignable
class TransferView: XibView {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: UIView!

    func setup(leg: Leg) {
        name.text = leg.name
        name.textColor = leg.bgColor
        background.backgroundColor = leg.fgColor
    }
}
