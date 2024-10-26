// swiftlint:disable:next file_header
import ComposableArchitecture
import Connection
import Foundation

public struct SocketFeature: Reducer {
    let settings: SettingsModel
    let connection: ConnectionModel

    public init(settings: SettingsModel, connection: ConnectionModel) {
        self.settings = settings
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
        case goesOffline
        case disconnect
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .connect:
            return Effect.run(operation: { _ in
                try await connection.socket(with: settings.websocketIP, port: settings.websocketPort)
            })
            .concatenate(with:
                .publisher {
                    connection
                        .socketState
                        .receive(on: RunLoop.main)
                        .replaceError(with: .disconnected)
                        .map { $0 == .online ? Self.Action.goesOnline : Self.Action.goesOffline }
                }
                // swiftlint:disable:next identifier_constant
                .cancellable(id: "SOCKET_ONLINE")
            )
            .concatenate(with: Effect.run(operation: { send in
                await send(.goesOnline)
            }))

        case .goesOnline:
            state = .online
            return .none

        case .goesOffline:
            state = .offline
            return .none

        case .disconnect:
            return .none
        }
    }
}
