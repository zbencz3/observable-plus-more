//
//  BitcoinTabViewModel.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit
import Perception
import CasePaths

struct Balance {
    let fiat: Amount<AnyCurrency>
    let bitcoin: Amount<Bitcoin>
}

fileprivate extension Balance {
    static func zeroBalance(currency: AnyCurrency) -> Balance {
        Balance(fiat: Amount(amount: 0, currency: currency), bitcoin: Amount(amount: 0, currency: .btc))
    }
}

enum Direction {
    case buy
    case sell
}

@MainActor
@Perceptible
final class BitcoinTabViewModel {
    let service: Service
    var balance: Balance
    var exchangeRate: Decimal
    #warning("Destination: makes sure you don't have invalid states, like if you were to use separate vars")
    /// Navigation destinations - nil means we are back to ourselves
    var destination: Destination?
    
    @CasePathable
    enum Destination: Equatable {
        case trade(Trade)
        case alert(Alert)
    }

    struct Trade: Identifiable, Equatable {
        var id: String {
            "\(direction)-\(sourceCurrency)-\(destinationCurrency)"
        }
        let direction: Direction
        let sourceCurrency: AnyCurrency
        let destinationCurrency: AnyCurrency
        
        init(
            direction: Direction,
            sourceCurrency: AnyCurrency,
            destinationCurrency: AnyCurrency
        ) {
            self.direction = direction
            self.sourceCurrency = sourceCurrency
            self.destinationCurrency = destinationCurrency
        }
    }

    struct Alert: Identifiable, Equatable {
        var id: String { "\(title)-\(message)" }
        let title: String
        let message: String
        
        init(
            title: String,
            message: String
        ) {
            self.title = title
            self.message = message
        }
    }
    
    init(
        service: Service,
        destination: Destination? = nil
    ) {
        self.service = service
        self.destination = destination
        self.balance = .zeroBalance(currency: .usd)
        self.exchangeRate = service.exchangeRate
        
        observe { [weak self] in
            guard let self else { return }
            
            self.exchangeRate = service.exchangeRate
            self.balance = Balance(
                fiat: service.balance,
                bitcoin: Amount<Bitcoin>(amount: service.bitcoinBalance.amount, currency: .btc)
            )
        }
    }
    
    func buyButtonTapped() {
        destination = .trade(
            Trade(
                direction: .buy,
                sourceCurrency: .usd,
                destinationCurrency: .btc
            )
        )
    }
    
    func sellButtonTapped() {
        destination = .trade(
            Trade(
                direction: .sell,
                sourceCurrency: .usd,
                destinationCurrency: .btc
            )
        )
    }
    
    func tradingBitcoinSucceeded() async {
        destination = nil
        
        /// Looks like cannot switch to a new destination immediately :sad
        try? await Task.sleep(for: .seconds(0.5))
        
        destination = .alert(
            Alert(
                title: "Trade Succeeded",
                message: "Bitcoin trade succeeded."
            )
        )
    }
    
    func tradingBitcoinFailed() async {
        destination = nil
        
        /// Looks like cannot switch to a new destination immediately :sad
        try? await Task.sleep(for: .seconds(0.5))
        
        destination = .alert(
            Alert(
                title: "Trade Failed",
                message: "Bitcoin trade failed. Please try again or contact customer support."
            )
        )
    }
    
    func tradeCancelled() {
        destination = nil
    }
    
    func didTapAlertOKButton() {
        destination = nil
    }
}
