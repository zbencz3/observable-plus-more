//
//  FontStyle.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

private class MonospaceDigitFontStyle: FontStyle {
    override var font: UIFont {
        super.font.monospacedDigitFont
    }
}

class FontStyle {
    init(fontSize: CGFloat, lineHeight: CGFloat, letterSpacing: CGFloat, fontName: FontStyle.FontName) {
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.fontName = fontName
    }
    
    enum FontName: String {
        case montserratBold = "Montserrat-Bold"
        case montserratMedium = "Montserrat-Medium"
        
        func font(withSize fontSize: CGFloat) -> UIFont {
            UIFont(name: rawValue, size: fontSize)!
        }
    }
    
    let fontSize: CGFloat
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    let fontName: FontName
    
    static let amount = FontStyle(fontSize: 80, lineHeight: 56, letterSpacing: -2, fontName: .montserratBold)
    static let headlineBig = FontStyle(fontSize: 23, lineHeight: 24, letterSpacing: -0.27, fontName: .montserratBold)
    static let headlineSmall = FontStyle(fontSize: 17, lineHeight: 24, letterSpacing: -0.2, fontName: .montserratBold)
    static let body = FontStyle(fontSize: 17, lineHeight: 24, letterSpacing: -0.2, fontName: .montserratMedium)
    
    static let sublineThin = FontStyle(fontSize: 13, lineHeight: 16, letterSpacing: -0.15, fontName: .montserratMedium)
    static let sublineThick = FontStyle(fontSize: 13, lineHeight: 16, letterSpacing: -0.15, fontName: .montserratBold)
    
    var font: UIFont {
        fontName.font(withSize: fontSize)
    }
    
    var monospaceDigits: FontStyle {
        MonospaceDigitFontStyle(fontSize: fontSize, lineHeight: lineHeight, letterSpacing: letterSpacing, fontName: fontName)
    }
}
