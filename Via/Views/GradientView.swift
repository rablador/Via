import UIKit

@IBDesignable
class GradientView: UIView {

    private var _startColor = UIColor.clear
    private var _endColor = UIColor.clear

    @IBInspectable var startColor: UIColor {
        get { return _startColor }
        set {
            _startColor = newValue
            setup()
        }
    }

    @IBInspectable var endColor: UIColor {
        get { return _endColor }
        set {
            _endColor = newValue
            setup()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
}

private extension GradientView {

    func setup() {
        let start = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: 1, y: 0)

        addGradientLayer(startPoint: start, endPoint: end, startColor: _startColor, endColor: _endColor)
    }

    func addGradientLayer(startPoint: CGPoint, endPoint: CGPoint, startColor: UIColor, endColor: UIColor) {
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint

        layer.addSublayer(gradientLayer)
    }
}
