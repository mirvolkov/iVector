import Combine
import Components
import ComposableArchitecture
import Connection
import Features
import Programmator
import SwiftUI

final class AppEnvironment: ObservableObject, @unchecked Sendable {
    let connection: ConnectionModel = .init()
    let config: Config = .init()
    let settings = SettingsModel()
    let assembler = AssemblerModel()
    let stt = SpeechToText()
    lazy var motion = MotionModelImpl(connection: connection)
}

struct AppFeature: Reducer {
    typealias FeatureStore = Store<State, Action>
    let env: AppEnvironment

    struct State: Equatable {
        var connection: ConnectionFeature<ExecutorModel>.State
        var motion: MotionFeature.State
        var socket: SocketFeature.State
        var camera: VisionFeature.State
        var audio: AudioFeature.State

        @MainActor static let initial: Self = .init(
            connection: .offline,
            motion: .offline,
            socket: .offline,
            camera: .offline,
            audio: .offline
        )
    }

    enum Action: Sendable {
        case motion(MotionFeature.Action)
        case connect(ConnectionFeature<ExecutorModel>.Action)
        case socket(SocketFeature.Action)
        case camera(VisionFeature.Action)
        case audio(AudioFeature.Action)
    }

    var body: some ReducerOf<AppFeature> {
        Reduce { state, action in
            switch action {
            case .connect(let action):
                switch action {
                case .connected:
                    state.connection = .online(ExecutorModel(with: env.connection))
                    return Effect.run { send in
                        await send(.motion(.connect))
                        await send(.socket(.connect))
                        await send(.camera(.connect))
                    }
                case .disconnect:
                    return Effect.run { send in
                        await send(.motion(.disconnect))
                        await send(.socket(.disconnect))
                        await send(.camera(.disconnect))
                    }
                default:
                    return .none
                }
            default:
                return .none
            }
        }

        Scope<AppFeature.State, AppFeature.Action, ConnectionFeature>(
            state: \.connection,
            action: /AppFeature.Action.connect
        ) {
            ConnectionFeature(
                settings: env.settings,
                env: env.config.device,
                connection: env.connection
            )
        }

        Scope<AppFeature.State, AppFeature.Action, MotionFeature>(
            state: \.motion,
            action: /AppFeature.Action.motion
        ) {
            MotionFeature(
                settings: env.settings,
                connection: env.connection,
                motionModel: env.motion
            )
        }

        Scope<AppFeature.State, AppFeature.Action, SocketFeature>(
            state: \.socket,
            action: /AppFeature.Action.socket
        ) {
            SocketFeature(
                settings: env.settings,
                connection: env.connection
            )
        }

        Scope<AppFeature.State, AppFeature.Action, VisionFeature>(
            state: \.camera,
            action: /AppFeature.Action.camera
        ) {
            VisionFeature(
                settings: env.settings,
                connection: env.connection
            )
        }

        Scope<AppFeature.State, AppFeature.Action, AudioFeature>(
            state: \.audio,
            action: /AppFeature.Action.audio
        ) {
            AudioFeature(
                settings: env.settings,
                connection: env.connection,
                stt: env.stt
            )
        }
    }
}

extension AppFeature.FeatureStore: ObservableObject {}
