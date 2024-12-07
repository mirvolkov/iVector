// swiftlint:disable:next file_header
import AVFoundation
import Connection
import Foundation
import SwiftBus

public final class SoundPlayer {
    public struct SoundName: Sendable, Codable {
        public let url: URL
    }

    public enum SoundType: String {
        case wav
    }

    public init() {}

    public static var all: [SoundName] {
        modules + main
    }

    private static var main: [SoundName] {
        Bundle.main
            .urls(forResourcesWithExtension: SoundType.wav.rawValue, subdirectory: nil)?
            .compactMap { $0 }
            .map { .init(url: $0) } ?? []
    }
    
    private static var modules: [SoundName] {
        Bundle.module
            .urls(forResourcesWithExtension: SoundType.wav.rawValue, subdirectory: nil)?
            .compactMap { $0 }
            .map { .init(url: $0) } ?? []
    }
    
    public func play(name: SoundPlayer.SoundName, type: SoundType = .wav) -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
            if let buf = readPCMBuffer(url: name.url) {
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

extension SoundPlayer.SoundName: CustomStringConvertible {
    public var description: String {
        url.lastPathComponent
    }
}
