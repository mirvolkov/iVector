import Foundation

public struct AudioFrame {
    /// The stream of sound that Vector hears, as a “mono audio amplitude samples”. This is 1600 “16-bit little-endian PCM audio” samples, at 11025 samples/sec.
    public let data: Data
    /// The “robot time at the transmission of this audio sample group”
    public let timestamp: UInt32
    /// 0-11: The index of the direction that the voice or key sound is coming. 12: There is no identifiable sound or the direction cannot be determined.
    public let direction: UInt32

    /// initializer
    public init(data: Data, timestamp: UInt32 = .zero, direction: UInt32 = .zero) {
        self.data = data
        self.timestamp = timestamp
        self.direction = direction
    }
}

public protocol Audio {
    /// Request Vector's mic feed
    /// - Returns AsyncStream type with frame
    /// - Throws error if request failed
    func requestMicFeed() throws -> AsyncStream<AudioFrame>

    /// Play audio
    func playAudio(stream: AsyncStream<AudioFrame>) throws
}
