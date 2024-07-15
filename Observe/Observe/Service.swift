//
//  Service.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import Foundation
import Perception

public typealias ApiCompletion<T> = (Result<T, Error>) -> Void

@MainActor
@Perceptible
final class Service {
    var exchangeRate: Decimal = 60000
    let minimumBuyAmount: Amount<AnyCurrency> = Amount(amount: 5, currency: .usd)
    let minimumSellAmount: Amount<AnyCurrency> = Amount(amount: 10, currency: .usd)
    var balance: Amount<AnyCurrency>
    var bitcoinBalance: Amount<AnyCurrency>
    
    private var timer: Timer?
    
    init(prepaidBalance: Amount<AnyCurrency>, bitcoinBalance: Amount<AnyCurrency>) {
        self.balance = prepaidBalance
        self.bitcoinBalance = bitcoinBalance
        
        startUpdatingPrice()
        
        Task {
            await currentBalance()
        }
    }
    
    deinit {
        // TODO: turn on complete concurrency checking
        // stopUpdatingPrice()
    }
    
    func tradeBitcoin(amount: Amount<AnyCurrency>, direction: Direction, completion: @escaping ApiCompletion<Void>) {
        guard amount.currency == .usd || amount.currency == .btc else {
            fatalError("Unsuported currency.")
        }
        
        let usdAmount: Decimal = amount.currency == .btc ? amount.amount * exchangeRate : amount.amount
        let btcAmount: Decimal = amount.currency == .btc ? amount.amount : amount.amount / exchangeRate
        
        switch direction {
        case .buy:
            guard usdAmount >= minimumBuyAmount.amount else {
                fatalError("Amount lower then minimum buy amount")
            }
            balance = Amount(amount: (balance.amount - usdAmount), currency: .usd)
            bitcoinBalance = Amount(amount: (bitcoinBalance.amount + btcAmount), currency: .btc)
        case .sell:
            guard usdAmount >= minimumSellAmount.amount else {
                fatalError("Amount lower then minimum sell amount")
            }
            
            guard btcAmount >= bitcoinBalance.amount else {
                fatalError("Amount higher then bitcoinBalance")
            }
            
            balance = Amount(amount: (balance.amount + usdAmount), currency: .usd)
            bitcoinBalance = Amount(amount: (bitcoinBalance.amount - btcAmount), currency: .btc)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            completion(.success(()))
        }
    }
}

private extension Service {
    /// Bitcoin price movements
    func startUpdatingPrice() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] timer in
            self?.updatePrice()
        }
    }
    
    func stopUpdatingPrice() {
        timer?.invalidate()
        timer = nil
    }
    
    func updatePrice() {
        let randomDouble = Double.random(in: 62000...64000)
        let decimalNumber = NSDecimalNumber(value: randomDouble)
        let handler = NSDecimalNumberHandler(
            roundingMode: .plain,
            scale: 2,
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        let roundedDecimalNumber = decimalNumber.rounding(accordingToBehavior: handler) as Decimal
        
        print("Updated Bitcoin price: \(roundedDecimalNumber)")
        exchangeRate = roundedDecimalNumber
    }
    
    /// Get the balance at startup
    func currentBalance() async {
        try? await Task.sleep(for: .seconds(2))
        
        balance = Amount(amount: Decimal(9910.96), currency: .usd)
        bitcoinBalance = Amount(amount: Decimal(2.1164), currency: .btc)
    }
}
