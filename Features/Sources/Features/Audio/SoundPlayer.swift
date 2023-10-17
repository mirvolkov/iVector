// swiftlint:disable:next file_header
import AVFoundation
import Connection
import Foundation
import SwiftBus

public final class SoundPlayer {
    public enum SoundType: String {
        case wav
        case mp3
    }

    public enum SoundName: String, CaseIterable, Codable, Sendable {
        case alarm
        case cputer1
        case cputer2
        case r2d21
        case r2d22
        case ping
        case scream
        case pcup
    }

    public init() {}

    public func play(name: SoundName, type: SoundType = .wav) -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
            guard let url = Bundle.module.url(forResource: name.rawValue, withExtension: type.rawValue) else {
                return
            }

            if let buf = readPCMBuffer(url: url) {
                guard let int16ChannelData = buf.int16ChannelData else {
                    return
                }

                let floatArray = UnsafeBufferPointer(start: int16ChannelData[0], count: Int(buf.frameLength))
                var data = Data()
                for buf in floatArray {
                    data.append(withUnsafeBytes(of: buf) { Data($0) })
                }
                continuation.yield(.init(data: data))
                continuation.finish()
            }
        }
    }

    func readPCMBuffer(url: URL) -> AVAudioPCMBuffer? {
        guard let input = try? AVAudioFile(forReading: url, commonFormat: .pcmFormatInt16, interleaved: false) else {
            return nil
        }
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: input.processingFormat,
            frameCapacity: AVAudioFrameCount(input.length)
        ) else {
            return nil
        }

        do {
            try input.read(into: buffer)
        } catch {
            return nil
        }

        return buffer
    }
}

extension SoundPlayer.SoundName: EventRepresentable { }
