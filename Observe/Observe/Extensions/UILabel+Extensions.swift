//
//  UILabel+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

extension UILabel {
    func set(text: String?, style: FontStyle = .body, color: UIColor = .white, alignment: NSTextAlignment = .center) {
        if let text = text {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = style.lineHeight - style.fontSize
            paragraphStyle.alignment = alignment
            attributedText = NSAttributedString(string: text, attributes: [
                .kern: style.letterSpacing,
                .paragraphStyle: paragraphStyle,
                .font: style.font,
                .foregroundColor: color,
            ])
            lineBreakMode = .byTruncatingTail
        } else {
            self.text = nil
        }
    }
}
