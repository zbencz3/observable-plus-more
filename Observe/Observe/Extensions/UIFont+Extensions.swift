//
//  UIFont+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

extension UIFont {
    var monospacedDigitFont: UIFont {
        let newFontDescriptor = fontDescriptor.monospacedDigitFontDescriptor
        return UIFont(descriptor: newFontDescriptor, size: 0)
    }
}

private extension UIFontDescriptor {
    var monospacedDigitFontDescriptor: UIFontDescriptor {
        let fontDescriptorFeatureSettings = [
            [
                UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector,
            ],
        ]
        let fontDescriptorAttributes = [
            UIFontDescriptor.AttributeName.featureSettings: fontDescriptorFeatureSettings,
        ]
        let fontDescriptor = self.addingAttributes(fontDescriptorAttributes)
        return fontDescriptor
    }
}
