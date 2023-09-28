// swiftlint:disable:next file_header
import ComposableArchitecture

public struct MotionFeature: ReducerProtocol {
    let settings: SettingsModel
    let connection: ConnectionModel
    let motionModel: MotionModel

    public init(settings: SettingsModel, connection: ConnectionModel, motionModel: MotionModel) {
        self.settings = settings
        self.connection = connection
        self.motionModel = motionModel
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
                    motionModel.start(connection: connection)
                })
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
                return Effect.run(operation: { _ in
                    motionModel.stop()
                }).concatenate(with: Effect.run(operation: { send in
                    await send(.goesOffline)
                }))
            }
        }
    }
}
