//
//  UINavigationItem+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//

import UIKit

extension UINavigationItem {
    func set(title: String, titleColor: UIColor = .gray, titleStyle: FontStyle = .headlineSmall, subtitle: String) {
        let titleLabel = UILabel()
        titleLabel.set(text: title, style: .headlineSmall, color: titleColor)
        
        let subtitleLabel = UILabel()
        subtitleLabel.set(text: subtitle, style: .sublineThin, color: .gray60Dark)
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        
        titleView = stackView
    }
}
