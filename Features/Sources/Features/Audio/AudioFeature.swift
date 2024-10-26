// swiftlint:disable:next file_header
import ComposableArchitecture
import Connection
import Foundation
import SocketIO
import SwiftBus

public struct AudioFeature: Reducer {
    public struct STTData: AppHub.SocketMessage {
        public let text: String
        public let data: Date = .init()

        public func socketRepresentation() throws -> SocketData {
            ["text": text, "timestamp": data.timeIntervalSince1970]
        }
    }

    private let settings: SettingsModel
    private let connection: ConnectionModel
    private let stt: SpeechToText
    private var socket: AppHub? { connection.hub }

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

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
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

            stt.start(currentLocale: .init(identifier: settings.locale))
            state = .connecting
            return .publisher {
                stt
                    .available
                    .removeDuplicates()
                    .replaceError(with: false)
                    .receive(on: RunLoop.main)
                    .map { $0 ? Self.Action.speechToTextGoesOnline : Self.Action.speechToTextGoesOffline }
            }
            // swiftlint:disable:next identifier_constant
            .cancellable(id: "STT_ONLINE")

        case .speechToTextStop:
            return .none

        case .speechToTextGoesOnline:
            state = .online
            return .publisher {
                stt
                    .text
                    .receive(on: RunLoop.main)
                    .map { Self.Action.speech($0) }
            }
            // swiftlint:disable:next identifier_constant
            .cancellable(id: "STT_CANCELLABLE")

        case .speechToTextGoesOffline:
            state = .offline
            return .none

        case .speech(let text):
            socket?.send(STTData(text: text), with: "stt")
            return .none
        }
    }
}
