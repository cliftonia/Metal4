//
//  Font+Retro.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

extension Font {
    /// The bundled Press Start 2P pixel typeface (OFL), for arcade-style UI text.
    static func pressStart(_ size: CGFloat) -> Font {
        .custom("PressStart2P-Regular", size: size)
    }
}
