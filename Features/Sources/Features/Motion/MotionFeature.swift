// swiftlint:disable:next file_header
import ComposableArchitecture

public struct MotionFeature: ReducerProtocol {
    let settings: SettingsModel
    let connection: ConnectionModel
    let motionModel: MotionModel

    public init(settings: SettingsModel, connection: ConnectionModel) {
        self.settings = settings
        self.connection = connection
        self.motionModel = MotionModelImpl(connection: connection)
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
        case motionRecognitionStart
        case motionRecognitionStop
        case motionLoggingStart
        case motionLoggingStop
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .connect:
            return Effect.run(operation: { _ in
                motionModel.start()
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

        case .motionRecognitionStart:
            motionModel.motionRecognitionStart()
            return .none

        case .motionRecognitionStop:
            motionModel.motionRecognitionStop()
            return .none

        case .motionLoggingStart:
            motionModel.motionLoggingStart()
            return .none

        case .motionLoggingStop:
            motionModel.motionLoggingStop()
            return .none
        }
    }
}
