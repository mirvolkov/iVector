import Combine
import Components
import ComposableArchitecture
import Features
import SwiftUI
import Programmator

enum VectorAppState: Equatable {
    case offline
    case online(VisionModel, ExecutorModel)
}

enum VectorAppAction {
    case connect(SettingsModel)
    case connected
    case disconnect
    case disconnected
}

final class VectorAppEnvironment: ObservableObject, Sendable {
    let connection: ConnectionModel = .init()
    let config: Config = .init()
    let settings = SettingsModel()
    let assembler = AssemblerModel()
}

let reducer = Reducer<VectorAppState, VectorAppAction, VectorAppEnvironment> { state, action, env in
    switch action {
    case .connect(let settings):
        return Effect.run { _ in
            switch env.config.device {
            case .mock:
                await env.connection.mock()
            case .vector:
                try await env.connection.connect(with: settings.ip, port: settings.port)
            case .pathfinder:
                try await env.connection.connect()
            }
        }.concatenate(with: Effect.task(operation: {
            VectorAppAction.connected
        }))

    case .connected:
        state = .online(
            VisionModel(with: env.connection),
            ExecutorModel(with: env.connection)
        )
        return .none

    case .disconnect:
        return Effect.task {
            env.connection.disconnect()
            return .disconnected
        }.concatenate(with: Effect.task(operation: {
            VectorAppAction.disconnected
        }))

    case .disconnected:
        state = .offline
        return .none
    }
}

typealias VectorStore = Store<VectorAppState, VectorAppAction>

extension VectorStore: ObservableObject {}
