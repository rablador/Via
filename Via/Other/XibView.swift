import UIKit

class XibView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup(name: className)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup(name: className)
    }
}
