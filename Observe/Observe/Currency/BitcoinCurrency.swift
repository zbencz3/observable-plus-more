//
//  BitcoinCurrency.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import Foundation

extension Amount where T == Bitcoin {
    var formatted: String {
        let currencyFormatter = NumberFormatter.bitcoin
        
        if amount == Decimal.nan {
            return currencyFormatter.string(from: 0)!.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return currencyFormatter.string(from: amount as NSDecimalNumber)!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
