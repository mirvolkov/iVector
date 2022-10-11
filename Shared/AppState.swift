import Combine
import Components
import ComposableArchitecture
import Features
import SwiftUI
import Programmator

enum VectorAppState: Equatable {
    case offline
    case online(VisionModel, ExecutorModel)

    fileprivate static var initial: Self {
        .offline
    }
}

enum VectorAppAction {
    case connect(SettingsModel)
    case connected
    case disconnect
    case disconnected
}

class VectorAppEnvironment {
    let connection: ConnectionModel = .init()
    let config: Config = .init()
    let assembler: AssemblerModel = .init()
    let settings: SettingsModel = .init()
#if os(iOS)
    let stt = STT.shared
#endif
}

let reducer = Reducer<VectorAppState, VectorAppAction, VectorAppEnvironment> { state, action, env in
    switch action {
    case .connect(let settings):
        return Effect.run { _ in
            if env.config.useMocked {
                await env.connection.mock()
            } else {
                await env.connection.connect(with: settings.ip, port: settings.port)
            }
        }

    case .connected:
        state = .online(VisionModel(with: env.connection), ExecutorModel(with: env.connection))
        return .none

    case .disconnect:
        return Effect.task {
            await env.connection.disconnect()
            return .disconnected
        }

    case .disconnected:
        state = .offline
        return .none
    }
}

final class AppState {
    static let env = VectorAppEnvironment()
    static let store = Store<VectorAppState, VectorAppAction>(initialState: .initial, reducer: reducer, environment: env)
    private var bag = Set<AnyCancellable>()

    func bind() {
        Task { @MainActor [self] in
            let viewStore = ViewStore<VectorAppState, VectorAppAction>(Self.store)
            await Self.env.connection
                .state
                .receive(on: RunLoop.main)
                .sink { state in
                    switch state {
                    case .connecting:
                        break

                    case .disconnected:
                        viewStore.send(.disconnected)

                    case .online:
                        viewStore.send(.connected)
                    }
                }
                .store(in: &self.bag)
        }
#if os(iOS)
        Task {
            Self.env.stt.start(currentLocale: .init(identifier: Self.env.settings.locale), onEdge:true)
        }
#endif
    }
}
