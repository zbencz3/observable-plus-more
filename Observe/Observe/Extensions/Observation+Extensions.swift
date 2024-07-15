//
//  Observation+Extensions.swift
//  Observe
//
//  Created by Zsolt Bencze on 15.07.2024.
//
//  Taken from https://www.pointfree.co/episodes/ep286-modern-uikit-tree-based-navigation

import Foundation
import Perception
import UIKit

@MainActor
func observe(
    apply: @escaping @MainActor @Sendable () -> Void
) {
    onChange(apply: apply)
}

@MainActor
func onChange(
    apply: @escaping @MainActor @Sendable () -> Void
) {
    withPerceptionTracking {
        apply()
    } onChange: {
        Task { @MainActor in
            if let animation = UIAnimation.current {
                UIView.animate(withDuration: animation.duration) {
                    onChange(apply: apply)
                }
            } else {
                onChange(apply: apply)
            }
        }
    }
}

extension NSObject {
    @MainActor
    func observe(
        apply: @escaping @MainActor @Sendable () -> Void
    ) {
        Observe.observe(apply: apply)
    }
}

struct UIAnimation {
    @TaskLocal fileprivate static var current: Self?
    var duration: TimeInterval
}

@MainActor
func withUIAnimation(
    _ animation: UIAnimation? = UIAnimation(duration: 0.3),
    body: @escaping () -> Void
) {
    UIAnimation.$current.withValue(animation) {
        body()
    }
}
