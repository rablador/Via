import UIKit

extension UIFont {

    func monospacedNumbers() -> UIFont {
        let bodyMonospacedNumbersFontDescriptor = fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [[
                UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
                ]]
            ])

        return UIFont(descriptor: bodyMonospacedNumbersFontDescriptor, size: 0.0)
    }
}
