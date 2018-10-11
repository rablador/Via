import UIKit

extension UIColor {

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)

        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }
}

extension UIColor {

    static var blue1: UIColor {
        get { return #colorLiteral(red: 0.09411764706, green: 0.1607843137, blue: 0.2392156863, alpha: 1) }
    }

    static var blue2: UIColor {
        get { return #colorLiteral(red: 0.1098039216, green: 0.1843137255, blue: 0.2705882353, alpha: 1) }
    }

    static var blue3: UIColor {
        get { return #colorLiteral(red: 0.1411764706, green: 0.2431372549, blue: 0.3647058824, alpha: 1) }
    }

    static var blue31: UIColor {
        get { return #colorLiteral(red: 0.168627451, green: 0.2745098039, blue: 0.4, alpha: 1) }
    }

    static var blue4: UIColor {
        get { return #colorLiteral(red: 0.2901960784, green: 0.4352941176, blue: 0.6078431373, alpha: 1) }
    }

    static var blue5: UIColor {
        get { return #colorLiteral(red: 0.5254901961, green: 0.7490196078, blue: 1, alpha: 1) }
    }

    static var blue6: UIColor {
        get { return #colorLiteral(red: 0.8039215686, green: 0.8980392157, blue: 1, alpha: 1) }
    }
}
