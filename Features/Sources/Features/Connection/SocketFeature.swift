import ComposableArchitecture
import Foundation
import Connection

public struct SocketFeature: ReducerProtocol {
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

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .connect:
                return Effect.run(operation: { _ in
                    try await connection.socket(with: settings.websocketIP, port: settings.websocketPort)
                })
                .concatenate(with:
                    connection.socketOnline
                        .receive(on: RunLoop.main)
                        .replaceError(with: false)
                        .catchToEffect()
                        .map { output in
                            guard let online = try? output.get() else {
                                return .goesOffline
                            }
                            return online ? Self.Action.goesOnline : Self.Action.goesOffline
                        }
                        // swiftlint:disable:next identifier_constant
                        .cancellable(id: "SOCKET_ONLINE"))
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
}
