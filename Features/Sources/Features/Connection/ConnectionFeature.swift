// swiftlint:disable:next file_header
import Combine
import ComposableArchitecture
import Foundation

public struct ConnectionFeature<Executor: Equatable>: ReducerProtocol {
    let settings: SettingsModel
    let env: EnvironmentDevice
    let connection: ConnectionModel

    public init(settings: SettingsModel, env: EnvironmentDevice, connection: ConnectionModel) {
        self.settings = settings
        self.env = env
        self.connection = connection
    }

    public enum State: Equatable {
        case offline
        case connecting
        case online(Executor)
    }

    public enum Action: Sendable {
        case connect
        case goesOnline
        case connected
        case goesOffline
        case disconnect
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .connect:
            if case .online = state {
                return .none
            }

            return Effect.run { send in
                await send(.goesOnline)
            }
            .concatenate(with: Effect.run { _ in
                try await connect()
            })
            .concatenate(with:
                connection
                    .connectionState
                    .receive(on: RunLoop.main)
                    .replaceError(with: .disconnected)
                    .map { $0 == .online ? Self.Action.connected : Self.Action.goesOffline }
                    .eraseToEffect()
                    // swiftlint:disable:next identifier_constant
                    .cancellable(id: "CONNECTION_ONLINE"))
            .concatenate(with: Effect.run(operation: { send in
                await send(.connected)
            }))

        case .goesOnline:
            state = .connecting
            return .none

        case .connected:
            return .none

        case .goesOffline:
            state = .offline
            return .none

        case .disconnect:
            guard case .online = state else {
                return .none
            }

            return Effect.run { _ in
                connection.disconnect()
            }
            .concatenate(with: Effect.run(operation: { send in
                await send(.goesOffline)
            }))
        }
    }

    private func connect() async throws {
        switch env {
        case .mock:
            await connection.mock()

        case .vector:
            try await connection.connect(
                with: settings.vectorIP,
                port: settings.vectorPort
            )

        case .pathfinder:
            try await connection.connect()
        }
    }
}
