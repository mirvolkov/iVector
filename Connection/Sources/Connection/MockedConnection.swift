import Foundation
import GRPC

public final class MockedConnection: Connection {
    public var delegate: ConnectionDelegate?
    private var eventStream: Task<Void, Error>?

    public func requestControl() throws {
        if Int.random(in: 0...10).isMultiple(of: 3) {
            delegate?.didFailedRequest()
            throw ConnectionError.notConnected
        }
        delegate?.didGrantedControl()
    }

    public func release() throws {
        eventStream?.cancel()
        delegate?.didClose()
    }

    public func initSdk() async throws {
        try await Task.sleep(nanoseconds: UInt64(Double.random(in: 0...1) * 1_000_000_000))
    }

    public func requestEventStream() throws {
        if Int.random(in: 0...100).isMultiple(of: 3) {
            throw ConnectionError.notConnected
        }

        eventStream = Task.detached(operation: {
            while true {
                self.delegate?.onRobot(state: try .init(jsonString: ""))
                try await Task.sleep(nanoseconds: UInt64(Double.random(in: 0...1) * 100_000_000))
            }
        })
    }
}

extension MockedConnection: Audio {
    public func requestMicFeed() throws -> AsyncStream<VectorAudioFrame> {
        .init { continuation in
            for _ in 0...1_000 {
                continuation.yield(.init(data: .init()))
                sleep(100_000_000)
            }

            continuation.finish()
        }
    }

    public func playAudio(stream: AsyncStream<VectorAudioFrame>) throws {}
}
