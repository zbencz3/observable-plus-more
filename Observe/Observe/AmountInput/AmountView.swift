//
//  AmountView.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

@MainActor
final class AmountView: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    var insets: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (insets.left + insets.right)
        }
    }
    
    private func setup() {
        backgroundColor = .clear
        textAlignment = .center
        textColor = .white
        
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.2
    }
    
    private enum SymbolPosition {
        case beginning
        case end
    }
    
    func set(value: Amount<AnyCurrency>, highlightCount: Int? = nil ) {
        let string = value.formatted.replacingOccurrences(of: "\u{00A0}", with: "")
        
        let font = FontStyle.amount.monospaceDigits.font
        let attributedText = NSMutableAttributedString(string: string, attributes: [
            .font: font,
            .foregroundColor: textColor ?? .white,
            .kern: -2,
        ])
        
        let dollarFont = FontStyle.headlineSmall.font
        let dollarOffset = font.capHeight - dollarFont.capHeight
        
        let range = (string as NSString).range(of: value.currency.symbol)
        
        attributedText.addAttributes([
            .font: dollarFont,
            .baselineOffset: dollarOffset,
        ], range: range)
        
        let kerning: CGFloat = 6
        let currencySymbolWidth = value.currency.symbol.size(withAttributes: [.font: dollarFont]).width + kerning
        
        let symbolPosition: SymbolPosition = range.location == 0 ? .beginning : .end
        
        let kerningRange: NSRange
        switch symbolPosition {
        case .beginning:
            kerningRange = range
            insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: currencySymbolWidth)
        case .end:
            kerningRange = NSRange(location: range.location - 1, length: 1)
            insets = UIEdgeInsets(top: 0, left: currencySymbolWidth, bottom: 0, right: 0)
            
            attributedText.addAttributes([
                .kern: kerning,
            ], range: NSRange(location: range.location, length: 1))
        }
        
        attributedText.addAttributes([
            .kern: kerning,
        ], range: kerningRange)
        
        if let highlightCount = highlightCount, highlightCount > 0 {
            let highlightRange: NSRange = {
                let length = string.count - highlightCount - 1
                switch symbolPosition {
                case .beginning:
                    return NSRange(location: highlightCount + 1, length: length)
                case .end:
                    return NSRange(location: highlightCount, length: length)
                }
            }()
            
            attributedText.addAttribute(.foregroundColor, value: UIColor.gray18Dark, range: highlightRange)
        }
        self.attributedText = attributedText
    }
}

