// swiftlint:disable:next file_header
import Combine
import Foundation
import SocketIO
import SwiftBus

private struct NamedMessage<Message: AppHub.SocketMessage>: EventRepresentable {
    let name: String
    let message: Message
}

public final class AppHub: @unchecked Sendable {
    public typealias SocketMessage = SocketData & EventRepresentable

    public enum EventIDs: String {
        case say
        case play
        case stt
        case objDetected
    }

    public enum SocketError: Error {
        case connectionError
        case invalidURL
    }

    public enum CachePolicy {
        case immediate
        case window(UInt)
        case never
    }

    public let online: CurrentValueSubject<Bool, SocketError> = .init(false)
    public var bag: Set<AnyCancellable> = []

    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private let eventBus: EventTransmittable = EventBus()
    private var cache: [String: [SocketData]] = [:]

    public init() {}

    public func connect(with websocketIP: String, websocketPort: Int) throws {
        guard let url = URL(string: "http://\(websocketIP):\(websocketPort)/") else {
            throw SocketError.invalidURL
        }

        manager = SocketManager(
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

        socket = manager?.defaultSocket
        socket?.on(clientEvent: .statusChange) { [weak self] _, _ in
            if self?.socket?.status == .connected {
                self?.online.send(true)
            } else {
                self?.online.send(false)
            }
        }

        socket?.connect()
    }

    public func disconnect() {
        socket?.disconnect()
    }
}

public extension AppHub {
    func send<Message: SocketMessage>(_ message: Message, with tag: String, cachePolicy: CachePolicy = .immediate) {
        eventBus.send(NamedMessage(name: tag, message: message))

        switch cachePolicy {
        case .immediate:
            socket?.emit(tag, with: [try? message.socketRepresentation()].compactMap { $0 })

        case .window(let limit):
            if cache[tag] == nil {
                cache[tag] = []
            }

            cache[tag]?.append(message)

            if let buffer = cache[tag] as? [Message], buffer.count >= limit {
                socket?.emit(tag, with: buffer.compactMap { try? $0.socketRepresentation() })
                cache[tag]?.removeAll()
            }

        case .never:
            break
        }
    }

    func listen<Message: SocketMessage>(_ tag: String, onRecieve: @escaping (Message) -> Void) {
        socket?.on(tag) { data, _ in
            if let message = data.first as? Message {
                onRecieve(message)
            }
        }

        eventBus
            .onReceive(NamedMessage<Message>.self, perform: { message in
                if tag == message.name {
                    onRecieve(message.message)
                }
            })
            .store(in: &bag)
    }
}
