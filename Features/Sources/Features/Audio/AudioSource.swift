import AVKit
import Combine
import Connection

protocol AudioSource {
    /// Request audio feed
    /// - Description existential type for audio feed
    /// - Throws if audio feed request failed
    /// - Returns async stream with audio feed chunks
    func feed() throws -> AsyncStream<VectorAudioFrame>
}
