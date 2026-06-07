//
//  BootChime.swift
//  Jimothy
//
//  Created by Clifton Baggerman on 07/06/2026.
//

import AVFoundation

/// Synthesises and plays a short ascending arpeggio at boot — a console power-on
/// chime, generated in code (no audio asset required). Respects the silent
/// switch via the ambient audio session.
enum BootChime {
    private static let engine = AVAudioEngine()
    private static let player = AVAudioPlayerNode()
    private static var isConfigured = false

    static func play() {
        let sampleRate = 44_100.0
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
            return
        }

        configureIfNeeded(format: format)

        guard let buffer = makeBuffer(format: format, sampleRate: sampleRate) else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
        } catch {
            return
        }

        player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        player.play()
    }

    private static func configureIfNeeded(format: AVAudioFormat) {
        guard !isConfigured else { return }
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        isConfigured = true
    }

    private static func makeBuffer(format: AVAudioFormat, sampleRate: Double) -> AVAudioPCMBuffer? {
        let notes: [Double] = [523.25, 659.25, 783.99, 1046.50] // C5 · E5 · G5 · C6
        let noteSeconds = 0.16
        let framesPerNote = Int(sampleRate * noteSeconds)
        let totalFrames = AVAudioFrameCount(framesPerNote * notes.count)

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: totalFrames) else {
            return nil
        }
        buffer.frameLength = totalFrames

        guard let channel = buffer.floatChannelData?[0] else { return nil }

        var frame = 0
        for frequency in notes {
            for sample in 0..<framesPerNote {
                let time = Double(sample) / sampleRate
                let attack = min(1.0, Double(sample) / 250.0)
                let decay = exp(-3.5 * time / noteSeconds)
                let value = sin(2 * .pi * frequency * time) * attack * decay * 0.3
                channel[frame] = Float(value)
                frame += 1
            }
        }
        return buffer
    }
}
