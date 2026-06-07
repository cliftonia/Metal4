//
//  ContentView.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI
import SpriteKit

/// The root layout: a screen above, a controller below — in the manner of a
/// handheld console. The boot (Apple → JIMOTHY title) plays in the top
/// two-thirds until the player presses Start, revealing the SpriteKit game. The
/// controller is a clamped footer that never disappears and drives the hero.
struct ContentView: View {
    @State private var started = false
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 400, height: 600))
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                ZStack {
                    SpriteView(scene: scene, options: [.ignoresSiblingOrder])

                    if !started {
                        LoadingScreen()
                            .transition(.opacity)
                    }
                }
                .frame(height: proxy.size.height * 2 / 3)
                .accessibilityLabel("Game screen")

                ControllerSection(
                    onUp: { pressing in pressing ? scene.startMoving(.up) : scene.stopMoving() },
                    onDown: { pressing in pressing ? scene.startMoving(.down) : scene.stopMoving() },
                    onLeft: { pressing in pressing ? scene.startMoving(.left) : scene.stopMoving() },
                    onRight: { pressing in pressing ? scene.startMoving(.right) : scene.stopMoving() },
                    onStart: startGame
                )
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
