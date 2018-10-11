import UIKit

extension UIResponder {

    var viewController: UIViewController? {
        if let vc = self as? UIViewController { return vc }
        return next?.viewController
    }
}
