//
//  ContentView.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

/// The root layout: a screen above, a controller below — in the manner of a
/// handheld console. The boot (Apple → JIMOTHY title) plays in the top
/// two-thirds until the player presses Start, revealing the game beneath. The
/// controller is a clamped footer that never disappears.
struct ContentView: View {
    @State private var started = false

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ZStack {
                    MetalView()

                    if !started {
                        LoadingScreen()
                            .transition(.opacity)
                    }
                }
                .frame(height: proxy.size.height * 2 / 3)
                .accessibilityLabel("Game screen")

                ControllerSection(onStart: startGame)
                    .frame(height: proxy.size.height / 3)
            }
        }
        .background(Color.black)
        .animation(.easeInOut(duration: 0.4), value: started)
    }

    private func startGame() {
        started = true
    }
}

#Preview {
    ContentView()
}
