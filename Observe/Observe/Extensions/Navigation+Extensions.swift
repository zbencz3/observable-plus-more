//
//  Navigation+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//
//  Taken from https://www.pointfree.co/episodes/ep286-modern-uikit-tree-based-navigation

import ObjectiveC
import UIKit
import SwiftUI

extension UIViewController {
    func present<Item: Identifiable>(
        item: UIBinding<Item?>,
        content: @escaping (Item) -> UIViewController
    ) {
        observe { [weak self] in
            guard let self else { return }
            if let unwrappedItem = item.wrappedValue {
                @MainActor
                func presentNewController() {
                    let controller = content(unwrappedItem)
                    controller.onDeinit = OnDeinit { [weak self] in
                        if AnyHashable(unwrappedItem.id) == self?.presented[item]?.id {
                            item.wrappedValue = nil
                        }
                    }
                    presented[item] = Presented(controller: controller, id: unwrappedItem.id)
                    present(controller, animated: true)
                }
                if let presented = presented[item] {
                    guard AnyHashable(unwrappedItem.id) != presented.id
                    else { return }
                    presented.controller?.dismiss(animated: true, completion: {
                        presentNewController()
                    })
                } else {
                    presentNewController()
                }
            } else if item.wrappedValue == nil, let controller = presented[item]?.controller {
                controller.dismiss(animated: true)
                presented[item] = nil
            }
        }
    }
    
    fileprivate var presented: [AnyHashable: Presented] {
        get {
            objc_getAssociatedObject(
                self,
                presentedKey
            ) as? [AnyHashable: Presented]
            ?? [:]
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
    
    fileprivate var onDeinit: OnDeinit? {
        get {
            objc_getAssociatedObject(
                self,
                onDeinitKey
            ) as? OnDeinit
        }
        set {
            objc_setAssociatedObject(
                self,
                onDeinitKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

extension UINavigationController {
    func pushViewController<Item>(
        item: UIBinding<Item?>,
        content: @escaping (Item) -> UIViewController
    ) {
        observe { [weak self] in
            guard let self else { return }
            if let unwrappedItem = item.wrappedValue, presented[item] == nil {
                let controller = content(unwrappedItem)
                controller.onDeinit = OnDeinit {
                    item.wrappedValue = nil
                }
                presented[item] = Presented(controller: controller)
                pushViewController(controller, animated: true)
            } else if item.wrappedValue == nil, let controller = presented[item]?.controller {
                popFromViewController(controller, animated: true)
                presented[item] = nil
            }
        }
    }
    
    private func popFromViewController(
        _ controller: UIViewController,
        animated: Bool
    ) {
        guard
            let index = viewControllers.firstIndex(of: controller),
            index != 0
        else {
            return
        }
        popToViewController(viewControllers[index - 1], animated: true)
    }
}

private let presentedKey = malloc(1)!
private let onDeinitKey = malloc(1)!

final fileprivate class OnDeinit {
    let onDismiss: () -> Void
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    deinit {
        onDismiss()
    }
}

fileprivate final class Presented {
    weak var controller: UIViewController?
    let id: AnyHashable?
    init(controller: UIViewController? = nil, id: AnyHashable? = nil) {
        self.controller = controller
        self.id = id
    }
}
