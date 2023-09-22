import Combine
import Foundation
import SocketIO

public final class SocketConnection: @unchecked Sendable  {
    public enum SocketError: Error {
        case connectionError
        case invalidURL
    }

    public let online: CurrentValueSubject<Bool, SocketError> = .init(false)

    private let manager: SocketManager
    private let socket: SocketIOClient
    private let url: URL

    public init(with websocketIP: String, websocketPort: Int) throws {
        guard let url = URL(string: "http://\(websocketIP):\(websocketPort)/") else {
            throw SocketError.invalidURL
        }

        self.url = url
        self.manager = SocketManager(
            socketURL: url,
            config: [
                .log(false),
                .secure(false),
                .connectParams(["EIO": 3]),
                .reconnects(true),
                .reconnectAttempts(Int.max),
                .reconnectWait(3)
            ]
        )
        self.socket = manager.defaultSocket
    }

    public func connect() {
        socket.on(clientEvent: .statusChange) { [weak self] _, _ in
            if self?.socket.status == .connected {
                self?.online.send(true)
                self?.online.send(completion: .finished)
            } else {
                self?.online.send(false)
            }
        }

        socket.on(clientEvent: .error) { [weak self] message, error in
            print((message, error))
            self?.online.send(completion: .failure(.connectionError))
        }

        socket.connect()
    }

    public func disconnect() {
        socket.disconnect()
    }

    public func send<Message: SocketData>(message: Message, with tag: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            socket.emit(tag, with: [message]) {
                continuation.resume()
            }
        }
    }
}
