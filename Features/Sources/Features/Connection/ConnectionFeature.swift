import ComposableArchitecture

public struct ConnectionFeature: ReducerProtocol {
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
        case online
    }

    public enum Action: Sendable {
        case connect
        case goesOnline
        case connected
        case goesOffline
        case disconnect
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .connect:
                return Effect.run { send in
                    await send(.goesOnline)
                }
                .concatenate(with: Effect.run { _ in
                    try await connect()
                })
                .concatenate(with: Effect.run(operation: { send in
                    await send(.connected)
                }))

            case .goesOnline:
                return .none

            case .connected:
                state = .online 
                return .none

            case .goesOffline:
                state = .offline
                return .none

            case .disconnect:
                return Effect.run { _ in
                    connection.disconnect()
                }
                .concatenate(with: Effect.run(operation: { send in
                    await send(.goesOffline)
                }))
            }
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
