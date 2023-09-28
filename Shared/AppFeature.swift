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
    let motion: MotionModel = MotionModelImpl()
}

struct AppFeature: ReducerProtocol {
    typealias FeatureStore = Store<State, Action>
    let env: AppEnvironment

    struct State: Equatable {
        var connection: ConnectionFeature.State
        var motion: MotionFeature.State
        var socket: SocketFeature.State
        static let initial: Self = .init(connection: .offline, motion: .offline, socket: .offline)
    }

    enum Action : Sendable{
        case motion(MotionFeature.Action)
        case connect(ConnectionFeature.Action)
        case socket(SocketFeature.Action)
    }

    var body: some ReducerProtocolOf<AppFeature> {
        Reduce { state, action in
            switch action {
            case .connect(let action):
                switch action {
                case .connected:
                    return Effect.run { send in
                        await send(.motion(.connect))
                    }.concatenate(with: Effect.run(operation: { send in
                        await send(.socket(.connect))
                    }))
                case .disconnect:
                    return Effect.run { send in
                        await send(.motion(.disconnect))
                    }.concatenate(with: Effect.run(operation: { send in
                        await send(.socket(.disconnect))
                    }))
                default:
                    return .none
                }
            case .motion:
                return .none
            case .socket:
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
    }
}

extension AppFeature.FeatureStore: ObservableObject {}
