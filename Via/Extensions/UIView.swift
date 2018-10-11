import UIKit

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @IBInspectable var borderColor: UIColor {
        get {
            guard let borderColor = layer.borderColor else { return .black }
            return UIColor(cgColor: borderColor)
        }
        set { layer.borderColor = newValue.cgColor }
    }

    func roundedCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))

        let mask = CAShapeLayer()
        mask.path = path.cgPath

        layer.mask = mask
        layer.masksToBounds = true
    }
}

extension UIView {

    var size: CGSize {
        get { return frame.size }
        set { frame.size = newValue }
    }

    var origin: CGPoint {
        get { return frame.origin }
        set { frame.origin = newValue }
    }

    var width: CGFloat {
        get { return frame.size.width }
        set { frame.size.width = newValue }
    }

    var height: CGFloat {
        get { return frame.size.height }
        set { frame.size.height = newValue }
    }

    var top: CGFloat {
        get { return frame.origin.y }
        set { frame.origin.y = newValue }
    }

    var bottom: CGFloat {
        return top + height
    }

    var left: CGFloat {
        get { return frame.origin.x }
        set { frame.origin.x = newValue }
    }

    var right: CGFloat {
        return left + width
    }

    func convertedFrame(for view: UIView, in container: UIView) -> CGRect {
        return container.convert(view.frame, to: self)
    }
}

extension UIView {

    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }

    func xibSetup(name: String) {
        guard let view = bundle.loadNibNamed(name, owner: self, options: nil)?.first as? UIView else {
            debugErrorPrint(DebugError("Could not load nib named \(name).", type: .fatal))
            fatalError()
        }

        view.frame = bounds
        addSubview(view)
    }
}

extension UIView {

    var isVisible: Bool { return alpha != 0 }

    static func animate(duration: Animation.Duration = .now, delay: Double = 0, animations: @escaping Callback, completion: Callback? = nil) {
        UIView.animate(withDuration: duration.rawValue, delay: delay, animations: animations, completion: { _ in completion?() })
    }

    func fadeTransition(duration: Animation.Duration = .now, completion: Callback? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({ completion?() })

        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration.rawValue

        layer.add(animation, forKey: convertFromCATransitionType(CATransitionType.fade))

        CATransaction.commit()
    }

    func fadeIn(duration: Animation.Duration = .now, alpha: Animation.Alpha = .opaque, completion: Callback? = nil) {
        setAlpha(alpha: alpha, animated: duration != .now, duration: duration, completion: completion)
    }

    func fadeOut(duration: Animation.Duration = .now, alpha: Animation.Alpha = .transparent, completion: Callback? = nil) {
        setAlpha(alpha: alpha, animated: duration != .now, duration: duration, completion: completion)
    }

    func setAlpha(alpha: Animation.Alpha, animated: Bool, duration: Animation.Duration, completion: Callback? = nil) {
        if animated {
            UIView.animate(duration: duration, animations: { self.alpha = CGFloat(alpha.rawValue) }, completion: completion)
        } else {
            self.alpha = CGFloat(alpha.rawValue)
            completion?()
        }
    }

    func setBackgroundColor(color: UIColor, duration: Animation.Duration = .now, completion: Callback? = nil) {
        UIView.animate(duration: duration, animations: { self.backgroundColor = color }, completion: completion)
    }
}

extension UIView {

    func curveAnimation(to destination: CGPoint, duration: Animation.Duration, completion: Callback? = nil) {
        curveAnimator(to: destination, duration: duration, completion: completion).startAnimation()
    }

    func curveAnimator(to destination: CGPoint, duration: Animation.Duration, completion: Callback? = nil) -> UIViewPropertyAnimator {
        let destination = CGRect(origin: destination, size: frame.size)

        let timing = UICubicTimingParameters(
            controlPoint1: CGPoint(x: 0.37, y: 0.42),
            controlPoint2: CGPoint(x: 0.25, y: 1)
        )

        let animator = UIViewPropertyAnimator(duration: duration.rawValue, timingParameters: timing)

        animator.addAnimations {
            self.frame = destination
        }
        animator.addCompletion { position in
            if position == .end { completion?() }
        }

        return animator
    }

    func springAnimation(to destination: CGPoint, duration: Animation.Duration, options: UIView.AnimationOptions = [], completion: Callback? = nil) {
        layer.removeAllAnimations()

        let destination = CGRect(origin: destination, size: frame.size)
        let animationOptions = options.union(.curveEaseInOut)

        UIView.animate(withDuration: duration.rawValue, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: animationOptions, animations: {
            self.frame = destination
        }, completion: { _ in completion?() })
    }
}

extension UIView {

    func showToast(text: String, width: Int, completion: Callback? = nil) {
        let toastWidth = CGFloat(width)
        let toastHeight = CGFloat(100)

        let toast = UILabel(frame: CGRect(x: (self.width / 2) - (toastWidth / 2), y: (self.height / 2) - (toastHeight / 2), width: toastWidth, height: toastHeight))

        toast.alpha = CGFloat(Animation.Alpha.transparent.rawValue)
        toast.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
        toast.textColor = .white
        toast.textAlignment = .center
        toast.text = text
        toast.numberOfLines = 2

        toast.layer.masksToBounds = true
        toast.layer.borderWidth = 1.0
        toast.layer.borderColor = UIColor.clear.cgColor
        toast.layer.cornerRadius = 8.0

        addSubview(toast)

        UIView.animate(duration: .fade, animations: { toast.alpha = CGFloat(Animation.Alpha.opaque.rawValue) }, completion: {
            UIView.animate(duration: .fade, delay: 2.0, animations: {
                toast.alpha = CGFloat(Animation.Alpha.transparent.rawValue)
            }, completion: {
                if nil != toast.superview {
                    toast.removeFromSuperview()
                }
            })
        })
    }
}

extension Optional where Wrapped == UIView {

    var isVisible: Bool { return self?.isVisible ?? false }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATransitionType(_ input: CATransitionType) -> String {
	return input.rawValue
}
