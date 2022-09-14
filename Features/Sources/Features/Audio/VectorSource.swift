import AVKit
import Combine
import Connection
import Foundation

public struct VectorSource: AudioSource {
    private let connection: Audio

    public init(with connection: Audio) {
        self.connection = connection
    }

    func feed() throws -> AsyncStream<VectorAudioFrame> {
        try connection.requestMicFeed()
    }
}
