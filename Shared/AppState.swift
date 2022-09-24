import Components
import ComposableArchitecture
import Features
import SwiftUI

enum VectorAppState: Equatable {
    case offline
    case online(VisionModel)

    fileprivate static var initial: Self {
        .offline
    }
}

enum VectorAppAction {
    case connect(SettingsModel)
    case connecting
    case disconnect
    case disconnecting
}

class VectorAppEnvironment {
    let connection: ConnectionModel = .init()
}

let reducer = Reducer<VectorAppState, VectorAppAction, VectorAppEnvironment> { state, action, env in
    switch action {
    case .connect(let settings):
        return Effect.task {
            await env.connection.connect(with: settings.ip, port: settings.port)
            return .connecting
        }

    case .connecting:
        state = .online(VisionModel(with: env.connection))
        return .none

    case .disconnecting:
        state = .offline
        return .none

    case .disconnect:
        return Effect.task {
            await env.connection.disconnect()
            return .disconnecting
        }
    }
}

struct AppState {
    static let env = VectorAppEnvironment()
    static let store = Store(initialState: .initial, reducer: reducer, environment: env)

    public static var instance = AppState()
}
