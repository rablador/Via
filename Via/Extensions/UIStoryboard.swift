import UIKit

extension UIStoryboard {

    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
}

extension UIStoryboard {

    func viewController<T: UIViewController>(ofType type: T.Type) -> T {
        let instance = type.init()
        let identifier = String(describing: Swift.type(of: instance))
        return instantiateViewController(withIdentifier: identifier) as! T
    }
}
