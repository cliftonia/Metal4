//
//  LoadingScreen.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

/// The boot, framed by animated angular-gradient borders. First the "system"
/// herald — the rainbow Apple — then the cartridge title screen: JIMOTHY in
/// Chrono Trigger gold with a blinking PRESS START prompt, awaiting the player.
struct LoadingScreen: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var stage: Stage = .system
    @State private var powerScaleY: CGFloat = 0.03
    @State private var flashOpacity: CGFloat = 0

    private enum Stage {
        case system
        case title
    }

    var body: some View {
        ZStack {
            content
                .id(stage)
                .transition(.opacity)

            Color.white
                .opacity(flashOpacity)
                .allowsHitTesting(false)
        }
        .scaleEffect(x: 1, y: powerScaleY, anchor: .center)
        .task { await boot() }
    }

    private func boot() async {
        BootChime.play()
        await powerOn()
        await runSequence()
    }

    /// The CRT power-on: a bright line snaps open to fill the screen with a flash.
    private func powerOn() async {
        guard !reduceMotion else {
            powerScaleY = 1
            return
        }
        flashOpacity = 0.85
        withAnimation(.easeOut(duration: 0.45)) { powerScaleY = 1 }
        withAnimation(.easeOut(duration: 0.6)) { flashOpacity = 0 }
        try? await Task.sleep(for: .seconds(0.45))
    }

    @ViewBuilder
    private var content: some View {
        switch stage {
        case .system:
            ZStack {
                Color.black
                AppleMark(size: 150)
            }
            .accessibilityElement()
            .accessibilityLabel("System loading")

        case .title:
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.05, green: 0.07, blue: 0.20), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
                VStack(spacing: 32) {
                    ChronoLogo(text: "JIMOTHY", fontSize: 50)
                        .padding(.vertical, 24)
                        .padding(.horizontal, 24)
                        .angularBorder(colors: [
                            Color(red: 0.95, green: 0.78, blue: 0.34),
                            .orange,
                            Color(red: 0.85, green: 0.55, blue: 0.16),
                            .teal,
                            Color(red: 0.95, green: 0.78, blue: 0.34)
                        ])
                        .padding(.horizontal, 16)

                    PressStartPrompt()
                }
            }
            .accessibilityElement()
            .accessibilityLabel("Jimothy. Press Start to begin.")
        }
    }

    private func runSequence() async {
        try? await Task.sleep(for: .seconds(reduceMotion ? 0.8 : 2.4))
        if reduceMotion {
            stage = .title
        } else {
            withAnimation(.easeInOut(duration: 0.5)) { stage = .title }
        }
    }
}

/// A blinking "PRESS START" prompt in the manner of a console title screen.
private struct PressStartPrompt: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var promptOpacity: CGFloat = 1

    var body: some View {
        Text("PRESS START")
            .font(.pressStart(11))
            .foregroundStyle(.white.opacity(0.9))
            .opacity(promptOpacity)
            .accessibilityLabel("Press Start")
            .task {
                guard !reduceMotion else { return }
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    promptOpacity = 0.15
                }
            }
    }
}

#Preview {
    LoadingScreen()
        .frame(height: 400)
}
