//
//  AppleMark.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

/// The classic six-stripe rainbow Apple mark, ringed by a spectrum border that
/// sweeps clockwise around its outline. The hero of the system boot stage.
struct AppleMark: View {
    let size: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double = 0
    @State private var entrance: CGFloat = 0

    private let stripes: [Color] = [
        Color(red: 0.42, green: 0.71, blue: 0.30),
        Color(red: 0.98, green: 0.79, blue: 0.10),
        Color(red: 0.95, green: 0.55, blue: 0.12),
        Color(red: 0.84, green: 0.19, blue: 0.16),
        Color(red: 0.47, green: 0.22, blue: 0.55),
        Color(red: 0.20, green: 0.46, blue: 0.76)
    ]

    private let spectrum: [Color] = [
        .red, .orange, .yellow, .green, .cyan, .blue, .purple, .red
    ]

    var body: some View {
        ZStack {
            apple(size * 1.14).foregroundStyle(border).blur(radius: 18).opacity(0.7)
            apple(size * 1.10).foregroundStyle(border).blur(radius: 3)
            apple(size).foregroundStyle(face)
        }
        .opacity(entrance)
        .scaleEffect(0.82 + 0.18 * entrance)
        .accessibilityHidden(true)
        .task { await animate() }
    }

    private func apple(_ pointSize: CGFloat) -> some View {
        Image(systemName: "apple.logo")
            .font(.system(size: pointSize))
    }

    /// Six hard-edged horizontal bands — the classic rainbow fill.
    private var face: LinearGradient {
        var stops: [Gradient.Stop] = []
        for (index, color) in stripes.enumerated() {
            let start = Double(index) / Double(stripes.count)
            let end = Double(index + 1) / Double(stripes.count)
            stops.append(.init(color: color, location: start))
            stops.append(.init(color: color, location: end))
        }
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }

    /// A full-spectrum conic gradient; rotating `angle` sweeps it clockwise.
    private var border: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: spectrum),
            center: .center,
            angle: .degrees(angle)
        )
    }

    private func animate() async {
        guard !reduceMotion else {
            entrance = 1
            return
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { entrance = 1 }
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            angle = 360
        }
    }
}

#Preview {
    ZStack {
        Color.black
        AppleMark(size: 150)
    }
    .ignoresSafeArea()
}
