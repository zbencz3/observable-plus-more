//
//  FiatCurrency.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import Foundation

extension Amount where T == AnyCurrency {
    var currencyFormatter: NumberFormatter {
        switch currency {
        case .btc:
            return NumberFormatter.bitcoin
        default:
            return NumberFormatter.fiat(currency: currency)
        }
    }
    
    var shortFormat: String {
        if amount == amount.roundUsdCeiling() {
            return formatted.replacingOccurrences(of: "\(Locale.current.decimalSeparator ?? ".")00", with: "")
        } else {
            return formatted
        }
    }
    
    var formatted: String {
        self.formatted(includeSymbol: true)
    }
    
    func formatted(includeSymbol: Bool) -> String {
        let formatter = self.currencyFormatter

        if !includeSymbol {
            formatter.currencySymbol = ""
        }

        if amount == Decimal.nan {
            return formatter.string(from: 0)!.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return formatter.string(from: amount as NSDecimalNumber)!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    public static func decimal(from string: String) -> Decimal? {
        let numberFormatter = NumberFormatter()
        numberFormatter.generatesDecimalNumbers = true
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.locale = Locale.autoupdatingCurrent
        numberFormatter.numberStyle = .decimal

        return ((numberFormatter.number(from: string)) as? NSDecimalNumber)?.decimalValue
    }
}

extension Decimal {
    func roundUsdCeiling() -> Decimal {
        var decimal = self
        var result = Decimal()
        NSDecimalRound(&result, &decimal, 2, .up)
        return result
    }
}
