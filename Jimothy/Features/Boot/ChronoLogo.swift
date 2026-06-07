//
//  ChronoLogo.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

/// A warm gold serif wordmark with a dark teal outline, evoking the Chrono
/// Trigger title treatment. Uses the system serif (commercial-safe) in place of
/// the paid ITC Serif Gothic.
struct ChronoLogo: View {
    let text: String
    let fontSize: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var entrance: CGFloat = 0
    @State private var glint: CGFloat = -1

    private let outlineOffsets: [CGSize] = [
        .init(width: -2, height: 0), .init(width: 2, height: 0),
        .init(width: 0, height: -2), .init(width: 0, height: 2),
        .init(width: -1.5, height: -1.5), .init(width: 1.5, height: 1.5)
    ]

    var body: some View {
        ZStack {
            outline
            face
        }
        .shadow(color: .black.opacity(0.5), radius: 6, y: 4)
        .opacity(entrance)
        .scaleEffect(0.92 + 0.08 * entrance)
        .task { await animate() }
    }

    private var glyphs: some View {
        Text(text)
            .font(.system(size: fontSize, weight: .heavy, design: .serif))
            .tracking(2)
    }

    private var outline: some View {
        ZStack {
            ForEach(outlineOffsets, id: \.self) { offset in
                glyphs
                    .foregroundStyle(Color(red: 0.04, green: 0.16, blue: 0.22))
                    .offset(x: offset.width, y: offset.height)
            }
        }
    }

    private var face: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                gold
                glintBand(width: width)
            }
            .frame(width: width, height: height)
            .mask {
                glyphs.frame(width: width, height: height)
            }
        }
        .frame(height: fontSize * 1.5)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var gold: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(red: 1.0, green: 0.96, blue: 0.78), location: 0.0),
                .init(color: Color(red: 0.95, green: 0.78, blue: 0.34), location: 0.45),
                .init(color: Color(red: 0.78, green: 0.55, blue: 0.16), location: 0.55),
                .init(color: Color(red: 0.62, green: 0.42, blue: 0.12), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func glintBand(width: CGFloat) -> some View {
        LinearGradient(
            colors: [.clear, .white.opacity(0.7), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: width * 0.22)
        .rotationEffect(.degrees(18))
        .offset(x: glint * width * 1.4)
        .blendMode(.plusLighter)
    }

    private func animate() async {
        guard !reduceMotion else {
            entrance = 1
            glint = 0.1
            return
        }

        withAnimation(.easeOut(duration: 0.5)) { entrance = 1 }
        try? await Task.sleep(for: .seconds(0.6))
        withAnimation(.linear(duration: 1.6).repeatForever(autoreverses: false)) {
            glint = 1
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(red: 0.04, green: 0.06, blue: 0.18), .black],
            startPoint: .top,
            endPoint: .bottom
        )
        ChronoLogo(text: "METAL", fontSize: 46)
    }
    .ignoresSafeArea()
}
