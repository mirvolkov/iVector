import AVKit
import Combine
import Connection
import Foundation

public struct VectorSource: AudioSource {
    private let mic: AsyncStream<VectorAudioFrame>

    public init(with mic: AsyncStream<VectorAudioFrame>) {
        self.mic = mic
    }

    public func feed() throws -> AsyncStream<VectorAudioFrame> {
        mic
    }
}
