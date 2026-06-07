//
//  Haptics.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import UIKit

/// Lightweight tactile feedback for controller input.
enum Haptics {
    /// A light tap, for directional and face buttons.
    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// A firmer thud, for system buttons like Start.
    static func confirm() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
