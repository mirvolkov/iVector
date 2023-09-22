import Combine
import Components
import ComposableArchitecture
import Features
import Programmator
import SwiftUI

final class VectorAppEnvironment: ObservableObject, Sendable {
    let connection: ConnectionModel = .init()
    let config: Config = .init()
    let settings = SettingsModel()
    let assembler = AssemblerModel()
    let motion = MotionModel()
}

struct VectorFeature: Reducer {
    typealias FeatureStore = Store<State, Action>
    let env: VectorAppEnvironment

    enum DeviceState: Equatable {
        case offline
        case online(VisionModel, ExecutorModel)
    }

    enum SocketState: Equatable {
        case offline
        case online
    }

    enum MotionState: Equatable {
        case offline
        case online
    }

    struct State: Equatable {
        var device: DeviceState = .offline
        var motion: MotionState = .offline
        var socket: SocketState = .offline
    }

    enum Action {
        case deviceConnect(SettingsModel)
        case deviceGoesOnline
        case deviceGoesOffline
        case deviceDisconnect

        case socketConnect
        case socketDisconnect
        case socketGoesOnline
        case socketGoesOffline

        case motionConnect
        case motionDisconnect
        case motionGoesOnline
        case motionGoesOffline
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .deviceConnect(let settings):
            return Effect.run { _ in
                switch env.config.device {
                case .mock:
                    await env.connection.mock()
                case .vector:
                    try await env.connection.connect(with: settings.vectorIP, port: settings.vectorPort)
                case .pathfinder:
                    try await env.connection.connect()
                }
            }
            .concatenate(with: Effect.run(operation: { send in
                await send(.socketConnect)
            }))
            .concatenate(with: Effect.run(operation: { send in
                await send(.motionConnect)
            }))
            .concatenate(with: Effect.run(operation: { send in
                await send(.deviceGoesOnline)
            }))

        case .deviceGoesOnline:
            state.device = .online(
                VisionModel(with: env.connection),
                ExecutorModel(with: env.connection)
            )
            return .none

        case .deviceGoesOffline:
            state.device = .offline
            return .none

        case .deviceDisconnect:
            return Effect.run { _ in
                env.connection.disconnect()
            }
            .concatenate(with: Effect.run(operation: { send in
                await send(.socketDisconnect)
            }))
            .concatenate(with: Effect.run(operation: { send in
                await send(.deviceGoesOffline)
            }))

        case .socketConnect:
            return Effect.run { send in
                try await env.connection.socket(with: env.settings.websocketIP, port: env.settings.websocketPort)
            }
            .concatenate(with: Effect.publisher {
                env.connection.socketOnline
                    .replaceError(with: false)
                    .map { online in
                        online ? .socketGoesOnline : .socketGoesOffline
                    }
            })

        case .socketDisconnect:
            env.connection.socket?.disconnect()
            return Effect.send(.socketGoesOffline)

        case .socketGoesOnline:
            state.socket = .online
            return Effect.send(.motionConnect)

        case .socketGoesOffline:
            state.socket = .offline
            return .none

        case .motionConnect:
            env.motion.start(connection: env.connection)
            return Effect.send(.motionGoesOnline)

        case .motionGoesOffline:
            return Effect.send(.motionGoesOffline)

        case .motionGoesOnline:
            state.motion = .online
            return .none

        case .motionDisconnect:
            env.motion.stop()
            state.motion = .offline
            return .none
        }
    }
}

extension VectorFeature.FeatureStore: ObservableObject {}
