//
//  BitcoinTabViewModelTests.swift
//  ObserveTests
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import XCTest
@testable import Observe

final class BitcoinTabViewModelTests: XCTestCase {
    
    var subject: BitcoinTabViewModel!
    var service: Service!

    @MainActor
    override func setUpWithError() throws {
        service = Service(
            prepaidBalance: Amount(
                amount: 1000,
                currency: .usd
            ),
            bitcoinBalance: Amount(
                amount: 1,
                currency: .btc
            )
        )
        subject = BitcoinTabViewModel(service: service)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    #warning("Testing the model")
    @MainActor
    func testBuyButton() throws {
        subject.buyButtonTapped()
        XCTAssertTrue(subject.destination == .trade(direction: .buy, sourceCurrency: .usd, destinationCurrency: .btc))
    }
    
    @MainActor
    func testSellButton() throws {
        subject.sellButtonTapped()
        XCTAssertTrue(subject.destination == .trade(direction: .sell, sourceCurrency: .usd, destinationCurrency: .btc))
    }
    
    @MainActor
    func testDidTapAlertOKButton() async throws {
        let expectation = XCTestExpectation(description: "Wait for tradingBitcoinSucceeded to complete")
        
        await subject.tradingBitcoinSucceeded()
        
        XCTAssertNotNil(subject.destination, "The variable should be non-nil after tradingBitcoinSucceeded")

        expectation.fulfill()

        /// There is a better way to do these things by controlling the time as a dependency, waiting in tests is not a good approach, but for now..
        await fulfillment(of: [expectation], timeout: 10.0)
        
        subject.didTapAlertOKButton()
        
        XCTAssertNil(subject.destination, "The variable should be nil after didTapAlertOKButton")
    }
}
