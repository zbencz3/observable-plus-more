//
//  AmountInputViewController.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

@MainActor
final class AmountInputViewController: UIViewController, AmountViewType {
    @IBOutlet weak var amountView: AmountView!
    @IBOutlet weak var keyPadView: KeyPadView!
    @IBOutlet private weak var requestButton: BackgroundButton!
    @IBOutlet private weak var amountContainerStackView: UIStackView!
    
    private let currency: AnyCurrency
    private let completion: ((AmountInputViewController, Amount<AnyCurrency>, @escaping () -> Void) -> Void)!
    var fiatAmount: Amount<AnyCurrency>
    var cancelBlock: (() -> Void)?
    
    var detailView: UIView?
    
    private init?(
        coder: NSCoder,
        currency: AnyCurrency,
        completion: @escaping (AmountInputViewController, Amount<AnyCurrency>, @escaping () -> Void) -> Void
    ) {
        self.currency = currency
        self.completion = completion
        self.fiatAmount = Amount<AnyCurrency>(amount: 0, currency: currency)
        
        super.init(coder: coder)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func instantiate(
        currency: AnyCurrency,
        completion: @escaping (AmountInputViewController, Amount<AnyCurrency>, @escaping () -> Void) -> Void
    ) -> AmountInputViewController {
        let storyboard = UIStoryboard(name: "AmountInput", bundle: nil)
        return storyboard.instantiateViewController(identifier: "AmountInputViewController") {
            AmountInputViewController(
                coder: $0,
                currency: currency,
                completion: completion
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if let detailView = detailView {
            amountContainerStackView?.insertArrangedSubview(detailView, at: 0)
        }
    
        requestButton.set(text: "Done")
        
        view.backgroundColor = .black
        amountView.set(value: fiatAmount)
        
        keyPadView.handler = { [weak self] in
            guard let self = self else { return false }
            let result = self.handleInput(string: $0, currency: self.currency)
            return result
        }
        
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .done, target: self, action: #selector(cancel))
            navigationItem.leftBarButtonItem?.tintColor = .white
        }
    }
    
    @IBAction private func continueButtonTapped(_ sender: Any) {
        execute(amount: fiatAmount)
    }
    
    private func execute(amount: Amount<AnyCurrency>) {
        requestButton.isEnabled = false
        completion(self, amount) { [weak self] in
            self?.requestButton.isEnabled = true
        }
    }
    
    @objc private func cancel() {
        cancelBlock?()
    }
}

