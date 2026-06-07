//
//  ControllerSection.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI

/// The bottom third: a directional pad, system buttons, and action buttons.
/// The left/right arrows drive the boot-screen style picker; other controls
/// are inert for now.
struct ControllerSection: View {
    var onLeft: () -> Void = {}
    var onRight: () -> Void = {}
    var onStart: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            SystemButtons(onStart: onStart)

            HStack(spacing: 40) {
                DirectionPad(onLeft: onLeft, onRight: onRight)
                    .frame(maxWidth: .infinity, alignment: .center)

                ActionButtons()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.12))
    }
}

/// A directional cross of four buttons. Buttons and spacing follow the 8pt grid;
/// the 160×160pt footprint mirrors the action button diamond.
private struct DirectionPad: View {
    var onLeft: () -> Void = {}
    var onRight: () -> Void = {}

    var body: some View {
        VStack(spacing: 8) {
            DPadButton(systemName: "chevron.up", label: "Up")
            HStack(spacing: 8) {
                DPadButton(systemName: "chevron.left", label: "Left", action: onLeft)
                Color.clear.frame(width: 48, height: 48)
                DPadButton(systemName: "chevron.right", label: "Right", action: onRight)
            }
            DPadButton(systemName: "chevron.down", label: "Down")
        }
    }
}

/// A single directional button.
private struct DPadButton: View {
    let systemName: String
    let label: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(Color(white: 0.25), in: RoundedRectangle(cornerRadius: 8))
        }
        .accessibilityLabel(label)
    }
}

/// The Select and Start system buttons, centred above the controls.
private struct SystemButtons: View {
    var onStart: () -> Void = {}

    var body: some View {
        HStack(spacing: 16) {
            SystemButton(title: "Select")
            SystemButton(title: "Start", action: onStart)
        }
    }
}

/// A single capsule-shaped system button.
private struct SystemButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color(white: 0.25), in: Capsule())
        }
        .accessibilityLabel("\(title) button")
    }
}

/// The four face buttons in a diamond: Y (top), X / B (sides), A (bottom).
/// Buttons and spacing follow the 8pt grid; the 160×160pt footprint mirrors
/// the directional pad, forming a square diamond.
private struct ActionButtons: View {
    var body: some View {
        VStack(spacing: 8) {
            ActionButton(title: "Y", color: .yellow)
            HStack(spacing: 64) {
                ActionButton(title: "X", color: .blue)
                ActionButton(title: "B", color: .red)
            }
            ActionButton(title: "A", color: .green)
        }
    }
}

/// A single circular face button.
private struct ActionButton: View {
    let title: String
    let color: Color

    var body: some View {
        Button {
            // TODO: wire to presenter action when behaviour is added.
        } label: {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(color, in: Circle())
        }
        .accessibilityLabel("\(title) button")
    }
}

#Preview {
    ControllerSection()
        .frame(height: 280)
}
