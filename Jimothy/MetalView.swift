//
//  MetalView.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import SwiftUI
import MetalKit
import os

/// Wraps an `MTKView` and its `Renderer` for use within the SwiftUI hierarchy.
/// Occupies the top two-thirds of the screen — the viewport.
struct MetalView: UIViewRepresentable {

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.backgroundColor = .black

        guard let device = MTLCreateSystemDefaultDevice() else {
            Self.logger.error("Metal is not supported on this device")
            return mtkView
        }
        mtkView.device = device

#if targetEnvironment(simulator)
        Self.logger.warning("Metal 4 is not supported on the simulator; presenting a blank surface")
        return mtkView
#else
        guard device.supportsFamily(.metal4) else {
            Self.logger.warning("Metal 4 is not supported on this device; presenting a blank surface")
            return mtkView
        }

        guard let renderer = Renderer(metalKitView: mtkView) else {
            Self.logger.error("Renderer could not be initialised")
            return mtkView
        }

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        mtkView.delegate = renderer
        context.coordinator.renderer = renderer
        return mtkView
#endif
    }

    func updateUIView(_ uiView: MTKView, context: Context) {}

    /// Holds the `Renderer` strongly, since `MTKView.delegate` is weak.
    final class Coordinator {
        var renderer: Renderer?
    }

    private static let logger = Logger(subsystem: "com.cliftonia.Jimothy", category: "MetalView")
}
