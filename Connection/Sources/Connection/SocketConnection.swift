// swiftlint:disable:next file_header
import Combine
import Foundation
import SocketIO
import SwiftBus

public final class SocketConnection: @unchecked Sendable {
    public enum SocketError: Error {
        case connectionError
        case invalidURL
    }

    public let online: CurrentValueSubject<Bool, SocketError> = .init(false)

    private let manager: SocketManager
    private let socket: SocketIOClient
    private let url: URL
    private var subscriptions: Set<AnyCancellable> = []
    private let eventBus: EventTransmittable = EventBus()

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
            } else {
                self?.online.send(false)
            }
        }

        socket.connect()
    }

    public func disconnect() {
        socket.disconnect()
    }
}

// socket API
public extension SocketConnection {
    func send<Message: SocketData>(message: Message, with tag: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            socket.emit(tag, with: [message]) {
                continuation.resume()
            }
        }
    }

    func send<Message: SocketData>(messages: [Message], with tag: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            socket.emit(tag, with: messages) {
                continuation.resume()
            }
        }
    }

    func listen<Message: SocketData>(_ tag: String, onRecieve: @escaping (Message) -> Void) {
        socket.on(tag) { data, _ in
            if let message = data.first as? Message {
                onRecieve(message)
            }
        }
    }
}

// event bus API
public extension SocketConnection {
    func send<Event: EventRepresentable>(event: Event, with tag: String) {
        eventBus.send(event)
    }

    func listen<Event: EventRepresentable>(_ tag: String, onRecieve: @escaping (Event) -> Void) {
        eventBus
            .onReceive(Event.self, perform: { event in
                onRecieve(event)
            })
            .store(in: &subscriptions)
    }
}
