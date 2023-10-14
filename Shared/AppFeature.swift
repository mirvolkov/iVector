import Combine
import Components
import ComposableArchitecture
import Connection
import Features
import Programmator
import SwiftUI

final class AppEnvironment: ObservableObject, Sendable {
    let connection: ConnectionModel = .init()
    let config: Config = .init()
    let settings = SettingsModel()
    let assembler = AssemblerModel()
}

struct AppFeature: ReducerProtocol {
    typealias FeatureStore = Store<State, Action>
    let env: AppEnvironment

    struct State: Equatable {
        var connection: ConnectionFeature.State
        var motion: MotionFeature.State
        var socket: SocketFeature.State
        var camera: VisionFeature.State
        var audio: AudioFeature.State
        static let initial: Self = .init(
            connection: .offline,
            motion: .offline,
            socket: .offline,
            camera: .offline, 
            audio: .offline
        )
    }

    enum Action: Sendable {
        case motion(MotionFeature.Action)
        case connect(ConnectionFeature.Action)
        case socket(SocketFeature.Action)
        case camera(VisionFeature.Action)
        case audio(AudioFeature.Action)
    }

    var body: some ReducerProtocolOf<AppFeature> {
        Reduce { _, action in
            switch action {
            case .connect(let action):
                switch action {
                case .connected:
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
            ConnectionFeature(settings: env.settings,
                              env: env.config.device,
                              connection: env.connection)
        }

        Scope<AppFeature.State, AppFeature.Action, MotionFeature>(
            state: \.motion,
            action: /AppFeature.Action.motion
        ) {
            MotionFeature(
                settings: env.settings,
                connection: env.connection
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
            VisionFeature(settings: env.settings,
                          connection: env.connection)
        }

        Scope<AppFeature.State, AppFeature.Action, AudioFeature>(
            state: \.audio,
            action: /AppFeature.Action.audio
        ) {
            AudioFeature(settings: env.settings,
                          connection: env.connection)
        }
    }
}

extension AppFeature.FeatureStore: ObservableObject {}
