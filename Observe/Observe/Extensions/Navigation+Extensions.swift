//
//  Navigation+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//
//  Taken from https://www.pointfree.co/episodes/ep286-modern-uikit-tree-based-navigation

import ObjectiveC
import UIKit

extension UIViewController {
    private var presented: UIViewController? {
        get {
            objc_getAssociatedObject(
                self,
                presentedKey
            ) as? UIViewController
        }
        set {
            objc_setAssociatedObject(
                self,
                presentedKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    func present<Item>(
        item: Item?,
        content: (Item) -> UIViewController
    ) {
        if let item, presented == nil {
            let controller = content(item)
            presented = controller
            present(controller, animated: true)
        } else if item == nil, let controller = presented {
            controller.dismiss(animated: true)
            presented = nil
        }
    }
}

private let presentedKey = malloc(1)!
