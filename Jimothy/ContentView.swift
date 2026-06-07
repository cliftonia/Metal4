//
//  ContentView.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

/// The root layout: a screen above, a controller below — in the manner of a
/// handheld console. The screen takes the top two-thirds; the controller the
/// bottom third.
struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                MetalView()
                    .frame(height: proxy.size.height * 2 / 3)
                    .accessibilityLabel("Game screen")

                ControllerSection()
                    .frame(height: proxy.size.height / 3)
            }
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
