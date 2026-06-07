//
//  AngularBorder.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

/// An animated rounded-rectangle border whose angular (conic) gradient sweeps
/// clockwise around the edge, with a soft matching glow. Wraps a logo group.
struct AngularBorder: ViewModifier {
    let colors: [Color]
    var cornerRadius: CGFloat = 26
    var lineWidth: CGFloat = 3

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(gradient, lineWidth: lineWidth)
                    .shadow(color: (colors.first ?? .clear).opacity(0.7), radius: 9)
            }
            .task {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                    angle = 360
                }
            }
    }

    private var gradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: colors + [colors.first ?? .clear]),
            center: .center,
            angle: .degrees(angle)
        )
    }
}

extension View {
    func angularBorder(
        colors: [Color],
        cornerRadius: CGFloat = 26,
        lineWidth: CGFloat = 3
    ) -> some View {
        modifier(AngularBorder(colors: colors, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}
