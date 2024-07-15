//
//  BackgroundButton.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

class BackgroundButton: UIButton {
    private weak var heightConstraint: NSLayoutConstraint?
    
    enum Style {
        case background
        case ghost
        case dark
    }
    
    convenience init() {
        self.init(frame: .zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let heightConstraint = heightAnchor.constraint(equalToConstant:  Constants.Button.height)
        self.heightConstraint = heightConstraint
        NSLayoutConstraint.activate([heightConstraint])
        setHeight(Constants.Button.height)
        layoutIfNeeded()
    }
    
    var style = Style.background {
        didSet {
            setup(style)
        }
    }
    
    func setup() {
        // TODO: fix it - use the new configuration options
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 48)
        titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        setup(style)
    }
    
    func setHeight(_ height: CGFloat) {
        heightConstraint?.constant = height
        layer.cornerRadius = height / 2
    }
    
    private func setup(_ style: Style) {
        switch style {
        case .background:
            setTitleColor(.black, for: .disabled)

            backgroundColor = .white
            tintColor = .black
            layer.borderWidth = 0
        case .ghost:
            setTitleColor(.gray60Dark, for: .disabled)

            backgroundColor = .clear
            tintColor = .white
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.cgColor
        case .dark:
            tintColor = .white
            backgroundColor = .elevation
            layer.borderWidth = 0
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            let stateColor = isEnabled ? UIColor.white : .gray60Dark
            
            switch style {
            case .background:
                setTitleColor(.black, for: .disabled)
                backgroundColor = stateColor
            case .ghost:
                setTitleColor(.gray60Dark, for: .disabled)
                layer.borderColor = stateColor.cgColor
            case .dark:
                fatalError("don't disable dark style background buttons.")
            }
        }
    }
    
    func setEnabled(_ isEnabled: Bool, animated: Bool) {
        guard isEnabled != self.isEnabled else { return }
        
        if animated {
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.isEnabled = isEnabled
            }
        } else {
            self.isEnabled = isEnabled
        }
    }
}
