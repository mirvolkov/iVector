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
        case connect(SettingsModel)
        case connected
        case disconnect
        case disconnected
        case socketConnect
        case socketConnected
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .connect(let settings):
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
            .concatenate(with: Effect.run(operation: { _ in
                try await env.connection.socket(with: env.settings.websocketIP, port: env.settings.websocketPort)
            }))
            .concatenate(with: Effect.run(operation: { send in
                await send(.connected)
            }))

        case .connected:
            state.device = .online(
                VisionModel(with: env.connection),
                ExecutorModel(with: env.connection)
            )
            state.socket = .online
            return .none

        case .disconnect:
            return Effect.run { send in
                env.connection.disconnect()
                await send(.disconnected)
            }.concatenate(with: Effect.run(operation: { send in
                await send(.disconnected)
            }))

        case .disconnected:
            state.device = .offline
            return .none

        case .socketConnect:
            state.socket = .offline
            return Effect.run { send in
                try await env.connection.socket(with: env.settings.websocketIP, port: env.settings.websocketPort)
                await send(.socketConnected)
            }

        case .socketConnected:
            state.socket = env.connection.socketOnline.value ? .online : .offline
            return .none
        }
    }
}

extension VectorFeature.FeatureStore: ObservableObject {}
