//
//  InputNumberFormatter.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import Foundation

final class InputNumberFormatter {
    private func numberFormatter(for input: String, exponent: Int) -> NumberFormatter? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = true

        let parts = input.components(separatedBy: numberFormatter.decimalSeparator)
        if parts.count > 2 {
            return nil
        } else if parts.count == 2 {
            let minimumFractionDigits = parts.last?.count ?? 0
            if minimumFractionDigits > exponent {
                return nil
            }
            numberFormatter.minimumFractionDigits = minimumFractionDigits
        } else {
            numberFormatter.minimumFractionDigits = 0
        }

        return numberFormatter
    }

    func validate(_ input: String) -> String? {
        guard
            let numberFormatter = numberFormatter(for: input, exponent: 2),
            let decimalSeparator = numberFormatter.decimalSeparator
            else { return nil }

        if input.isEmpty {
            return ""
        } else if input == decimalSeparator {
            return "0\(decimalSeparator)"
        } else if input == "00" {
            return nil
        }

        if let number = numberFormatter.number(from: input),
            let result = numberFormatter.string(from: number) {

            if input.hasSuffix(decimalSeparator) {
                return result + decimalSeparator
            } else {
                return result
            }
        } else {
            return nil
        }
    }
}
