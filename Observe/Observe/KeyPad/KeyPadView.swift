//
//  KeyPadView.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import AudioToolbox
import UIKit

@MainActor
class KeyPadView: UIView {
    @IBOutlet private var contentView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        Bundle.main.loadNibNamed("KeyPadView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        backgroundColor = .black

        updateButtonFont()
    }

    override var backgroundColor: UIColor? {
        didSet {
            contentView?.backgroundColor = backgroundColor
        }
    }

    var isEnabled: Bool = true {
        didSet {
            updateButtonState()
        }
    }

    var handler: ((String) -> Bool)?
    var customPointButtonAction: (() -> Void)?

    var textColor = UIColor.white {
        didSet {
            updateButtonFont()
        }
    }
    var disabledColor = UIColor.gray18Dark {
        didSet {
            updateButtonFont()
        }
    }

    @IBOutlet private var buttons: [UIButton]?
    @IBOutlet private weak var pointButton: UIButton! {
        didSet {
            updatePointButton()
        }
    }

    var numberString = "" {
        didSet {
            guard oldValue != numberString else { return }
        }
    }

    private var pointCharacter: String {
        Locale.autoupdatingCurrent.decimalSeparator ?? "."
    }

    private func updateButtonFont() {
        buttons?.forEach {
            $0.setTitleColor(disabledColor, for: .disabled)
            $0.setTitleColor(textColor, for: .normal)
            $0.imageView?.tintColor = textColor
            $0.titleLabel?.font = FontStyle.headlineBig.monospaceDigits.font.withSize(25)
        }
    }

    private func updateButtonState() {
        buttons?.forEach { [isEnabled] in
            $0.isEnabled = isEnabled
        }
    }

    private func updatePointButton() {
        pointButton.setImage(nil, for: .normal)
        pointButton.setTitle(pointCharacter, for: .normal)
        pointButton.isEnabled = true
    }

    private func numberTapped(_ number: Int) {
        if numberString == "0" {
            proposeNumberString(String(describing: number))
        } else {
            proposeNumberString(numberString + String(describing: number))
        }
    }

    private func pointTapped() {
        if let customPointButtonAction = customPointButtonAction {
            customPointButtonAction()
        } else {
            proposeNumberString(numberString + pointCharacter)
        }
    }

    private func backspaceTapped() {
        proposeNumberString(String(numberString.dropLast()))
    }

    @IBAction private func buttonTapped(_ sender: UIButton) {
        #if !targetEnvironment(simulator)
        AudioServicesPlaySystemSound(0x450)
        #endif
        
        if sender.tag < 10 {
            numberTapped(sender.tag)
        } else if sender.tag == 10 {
            pointTapped()
        } else {
            backspaceTapped()
        }
    }

    private var deleteTimer: Timer?

    @IBAction private func longPressChanged(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
                DispatchQueue.main.async { [weak self] in
                    self?.backspaceTapped()
                }
            }
            deleteTimer?.fire()
        case .ended:
            deleteTimer?.invalidate()
        default:
            break
        }
    }

    private func proposeNumberString(_ string: String) {
        guard string != numberString else { return }

        if let handler = handler {
            if handler(string) {
                numberString = string
            }
        } else {
            numberString = string
        }
    }
}
