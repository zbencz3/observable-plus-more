//
//  NumberFormatter+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import Foundation

extension NumberFormatter {
    static func fiat(currency: AnyCurrency) -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.generatesDecimalNumbers = true
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.autoupdatingCurrent
        currencyFormatter.currencyCode = currency.rawValue
        currencyFormatter.currencySymbol = currency.symbol
        return currencyFormatter
    }
    
    static var bitcoin: NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.generatesDecimalNumbers = true
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.autoupdatingCurrent
        currencyFormatter.currencyCode = "BTC"
        currencyFormatter.currencySymbol = "BTC"
        currencyFormatter.maximumFractionDigits = 10
        return currencyFormatter
    }
}
