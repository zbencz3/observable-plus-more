//
//  FiatAmount.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import Foundation

public struct Amount<T: Hashable & Codable & RawRepresentable>: Equatable, Hashable where T.RawValue == String {
    public let amount: Decimal
    public let currency: T
    
    public init(amount: Decimal, currency: T) {
        self.amount = amount
        self.currency = currency
    }
}

extension Amount: Codable {
    enum CodingKeys: String, CodingKey {
        case amount
        case currency
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let amount = Decimal(string: try values.decode(String.self, forKey: .amount)) else {
            throw DecodingError.dataCorruptedError(forKey: .amount, in: values, debugDescription: "amount string can not be converted to decimal")
        }
        
        self.amount = amount
        currency = try values.decode(T.self, forKey: .currency)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount.description, forKey: .amount)
        try container.encode(currency.rawValue, forKey: .currency)
    }
}

// MARK: - Currencies

public enum AnyCurrency: String, Codable, CustomStringConvertible, Equatable {
    case btc = "BTC"
    case usd = "USD"
    case euro = "EUR"
    case tether = "USDT"
    
    public var description: String { rawValue }

    public var symbol: String {
        switch self {
        case .euro:
            return "€"
        case .usd, .tether:
            return "$"
        case .btc:
            return "BTC"
        }
    }
    
    public var iso: String {
        switch self {
        case .usd, .euro, .btc:
            return rawValue
        case .tether:
            return AnyCurrency.usd.iso
        }
    }
}

public enum Bitcoin: String, Codable {
    case btc = "BTC"
}
