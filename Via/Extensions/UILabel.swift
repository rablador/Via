import UIKit

extension UILabel {

    func setTextColor(color: UIColor, duration: Animation.Duration = .now, completion: Callback? = nil) {
        if duration == .now {
            self.textColor = color
            completion?()
            return
        }

        UIView.transition(with: self, duration: duration.rawValue, options: .transitionCrossDissolve, animations: {
            self.textColor = color
        }) { _ in completion?() }
    }
}
