import UIKit

extension UIViewController {

    func addOverlay(viewController: UIViewController, frame: CGRect, fade: Bool = false, completion: Callback? = nil) {
        createOverlay(viewController: viewController, frame: frame, fade: fade, completion: completion)
        view.addSubview(viewController.view)
    }

    func addOverlay(viewController: UIViewController, container: UIView, fade: Bool = false, completion: Callback? = nil) {
        let frame = CGRect(x: 0, y: 0, width: container.width, height: container.height)
        createOverlay(viewController: viewController, frame: frame, fade: fade, completion: completion)
        container.addSubview(viewController.view)
    }

    func removeOverlay(viewController: UIViewController, fade: Bool = false, completion: Callback? = nil) {
        UIView.animate(duration: fade ? .fade : .now, animations: { viewController.view.alpha = CGFloat(Animation.Alpha.transparent.rawValue) }, completion: {
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()

            completion?()
        })
    }

    func childViewControllers<T>(ofType type: T.Type) -> [T] {
        return children.compactMap { $0 as? T }
    }

    func createOverlay(viewController: UIViewController, frame: CGRect, fade: Bool = false, completion: Callback? = nil) {
        addChild(viewController)
        viewController.didMove(toParent: self)

        viewController.view.alpha = 0
        viewController.view.frame = frame

        UIView.animate(duration: fade ? .fade : .now, animations: { viewController.view.alpha = CGFloat(Animation.Alpha.opaque.rawValue) }, completion: completion)
    }
}
