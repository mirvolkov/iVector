// swiftlint:disable:next file_header
import ComposableArchitecture
import Connection
import Foundation

public struct AudioFeature: ReducerProtocol {
    private let settings: SettingsModel
    private let connection: ConnectionModel
    private let tts = TextToSpeech()
    private let stt = SpeechToText()

    public init(settings: SettingsModel, connection: ConnectionModel) {
        self.settings = settings
        self.connection = connection
    }

    public enum State: Equatable {
        case offline
        case connecting
        case online
    }

    public enum Action: Sendable {
        case say(String)
        case play(SoundPlayer.SoundName)
        case speechToTextStart
        case speechToTextStop
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .say(let text):
            return Effect.run { _ in
                let stream = tts.run(text, locale: .init(identifier: settings.locale))
                try await connection.audio?.playAudio(stream: stream)
            }

        case .play(let sound):
            return Effect.run { _ in
                let player = SoundPlayer()
                let stream = player.play(name: sound)
                try await connection.audio?.playAudio(stream: stream)
            }

        case .speechToTextStart:
            stt.start()
            return .none

        case .speechToTextStop:
            stt.stop()
            return .none
        }
    }
}
