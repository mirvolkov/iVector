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
    case stt(String)
}

class VectorAppEnvironment {
    let connection: ConnectionModel = .init()
    let config: Config = .init()
    let assembler: AssemblerModel = .init()
    let settings: SettingsModel = .init()
    var stt: SpeechRecognizer?

    init() {
#if os(iOS)
        self.stt = STT.shared
#endif
    }
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
        state = .online(
            VisionModel(with: env.connection),
            ExecutorModel(with: env.connection)
        )
        return .none

    case .disconnect:
        return Effect.task {
            await env.connection.disconnect()
            return .disconnected
        }

    case .disconnected:
        state = .offline
        return .none

    case .stt(let text):
        switch state {
        case .offline:
            break
        case .online(_, let executorModel):
            executorModel.input(text: text)
        }
        return .none
    }
}

final class AppState {
    static let env = VectorAppEnvironment()
    static let store = Store<VectorAppState, VectorAppAction>(initialState: .initial, reducer: reducer, environment: env)
    private var bag = Set<AnyCancellable>()

    func bind() {
        let viewStore = ViewStore<VectorAppState, VectorAppAction>(Self.store)
        
        Task { @MainActor [self] in
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

        Task {
            Self.env.stt?.stt
                .map { VectorAppAction.stt($0) }
                .receive(on: RunLoop.main)
                .sink { [weak viewStore] action in
                    viewStore?.send(action)
                }
                .store(in: &bag)

            Self.env.stt?.start(
                currentLocale: .init(identifier: Self.env.settings.locale),
                onEdge:true
            )
        }
    }
}
