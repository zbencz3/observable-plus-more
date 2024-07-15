//
//  UIButton+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

extension UIButton {
    func set(text: String, style: FontStyle = .headlineSmall, animated: Bool = false) {
        func set() {
            setAttributedTitle(
                NSAttributedString(string: text, attributes: [
                    .kern: style.letterSpacing,
                    .font: style.font,
                ]),
                for: .normal
            )
        }
        
        if animated {
            set()
        } else {
            UIView.performWithoutAnimation {
                set()
                self.layoutIfNeeded()
            }
        }
    }
}
