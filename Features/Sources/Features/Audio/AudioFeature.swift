// swiftlint:disable:next file_header
import ComposableArchitecture
import Connection
import Foundation
import SwiftBus

public struct AudioFeature: ReducerProtocol {
    public struct STTData: EventRepresentable {
        public let text: String
    }

    private let settings: SettingsModel
    private let connection: ConnectionModel
    private let stt: SpeechToText
    private var socket: SocketConnection? { connection.socket }

    public init(settings: SettingsModel, connection: ConnectionModel, stt: SpeechToText) {
        self.settings = settings
        self.connection = connection
        self.stt = stt
    }

    public enum State: Equatable {
        case offline
        case connecting
        case online

        public var isOnline: Bool {
            switch self {
            case .online:
                return true

            default:
                return false
            }
        }
    }

    public enum Action: Sendable {
        case say(String)
        case play(SoundPlayer.SoundName)
        case speechToTextStart
        case speechToTextGoesOnline
        case speechToTextGoesOffline
        case speechToTextStop
        case speech(String)
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .say(let text):
            return Effect.run { _ in
                try await connection.say(text: text)
            }

        case .play(let sound):
            return Effect.run { _ in
                try await connection.play(name: sound)
            }

        case .speechToTextStart:
            guard !state.isOnline else {
                return .none
            }

            stt.start()
            state = .connecting
            return stt
                .available
                .removeDuplicates()
                .replaceError(with: false)
                .receive(on: RunLoop.main)
                .map({ $0 ? Self.Action.speechToTextGoesOnline : Self.Action.speechToTextGoesOffline })
                .eraseToEffect()
                // swiftlint:disable:next identifier_constant
                .cancellable(id: "SOCKET_ONLINE")

        case .speechToTextStop:
            return .none

        case .speechToTextGoesOnline:
            state = .online
            return stt
                .text
                .receive(on: RunLoop.main)
                .map({ Self.Action.speech($0) })
                .eraseToEffect()
                // swiftlint:disable:next identifier_constant
                .cancellable(id: "STT_CANCELLABLE")

        case .speechToTextGoesOffline:
            state = .offline
            return .none

        case .speech(let text):
            socket?.send(event: STTData(text: text))
            socket?.send(
                message: [
                    "text": text,
                    "timestamp": Date().timeIntervalSince1970
                ],
                with: "stt",
                cachePolicy: .immediate
            )
            return .none
        }
    }
}
