//
//  AmountViewType.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import Foundation

@MainActor
protocol AmountViewType: AnyObject {
    var fiatAmount: Amount<AnyCurrency> { get set }
    var amountView: AmountView! { get set }
    var keyPadView: KeyPadView! { get set }
    
    func handleInput(string: String, currency: AnyCurrency) -> Bool
}

extension AmountViewType {
    func handleInput(string: String, currency: AnyCurrency) -> Bool {
        let numberFormatter = InputNumberFormatter()
        guard var output = numberFormatter.validate(string) else { return false }
        if output.isEmpty {
            output = "0"
        }
        
        let amount = Amount<AnyCurrency>.decimal(from: string) ?? 0
        guard amount <= 99999 else { return false }
        
        fiatAmount = Amount<AnyCurrency>(amount: amount, currency: currency)
    
        let count = string.isEmpty ? 0 : output.count
        amountView.set(value: fiatAmount, highlightCount: count)
        
        return true
    }
}
