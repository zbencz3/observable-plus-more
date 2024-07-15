//
//  BitcoinTabViewController.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit
import Perception
import SwiftUINavigation

class BitcoinTabViewController: UIViewController {
    private var collectionView: UICollectionView!
    private lazy var buttonsStackView = UIStackView()
    private lazy var buyButton = BackgroundButton()
    private lazy var sellButton = BackgroundButton()
    
    private let viewModel: BitcoinTabViewModel

    init(viewModel: BitcoinTabViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        
        view.backgroundColor = .black
        
        buyButton.set(text: "Buy")
        buyButton.style = .dark
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        
        sellButton.set(text: "Sell")
        sellButton.style = .dark
        sellButton.addTarget(self, action: #selector(sellButtonTapped), for: .touchUpInside)
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 8
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.heightAnchor.constraint(equalToConstant: 56),
            buttonsStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        buttonsStackView.addArrangedSubview(buyButton)
        buttonsStackView.addArrangedSubview(sellButton)

        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -25),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        #warning("UIKit observing the model properties and updating views, preseting view controllers")
        observe { [weak self] in
            guard let self else { return }
            
            self.renderBalance(balance: viewModel.balance)
            self.renderExchangerate(exchangeRate: viewModel.exchangeRate, balance: viewModel.balance)
            
            present(item: viewModel.destination) { [viewModel] destination in
                switch destination {
                case .trade(let direction, let sourceCurrency, _):
                    let amountInputViewController = AmountInputViewController.instantiate(currency: sourceCurrency) { [viewModel] viewController, amount, completion in
                        /// Since we only have the BTC tab we can ignore the destination currency and trade bitcoin.
                        viewModel.service.tradeBitcoin(amount: amount, direction: direction) { result in
                            switch result {
                            case .success(_):
                                Task {
                                    await viewModel.tradingBitcoinSucceeded()
                                }
                            case .failure(_):
                                Task {
                                    await viewModel.tradingBitcoinFailed()
                                }
                            }
                            completion()
                        }
                    }
                    amountInputViewController.cancelBlock = {
                        viewModel.tradeCancelled()
                    }
                    return UINavigationController(rootViewController: amountInputViewController)
                case .alert(let title, let message):
                    let alertController = UIAlertController(
                        title: title,
                        message: message,
                        preferredStyle: .alert
                    )
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                        viewModel.didTapAlertOKButton()
                    }))
                    return alertController
                }
            }
        }
    }
    
    @objc private func buyButtonTapped() {
        viewModel.buyButtonTapped()
    }
    
    @objc private func sellButtonTapped() {
        viewModel.sellButtonTapped()
    }
    
    private func renderBalance(balance: Balance) {
        navigationItem.set(
            title: balance.fiat.formatted,
            titleColor: UIColor.white,
            titleStyle: .headlineBig,
            subtitle: balance.bitcoin.formatted
        )
    }
    
    private func renderExchangerate(exchangeRate: Decimal, balance: Balance) {
        navigationItem.set(
            title: balance.fiat.formatted,
            titleColor: UIColor.white,
            titleStyle: .headlineBig,
            subtitle: [balance.bitcoin.formatted, "@\(exchangeRate)"].joined(separator: " ")
        )
    }
}
