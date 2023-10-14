// swiftlint:disable:next file_header
import ComposableArchitecture
import Foundation

public struct VisionFeature: ReducerProtocol {
    let settings: SettingsModel
    let connection: ConnectionModel

    public init(settings: SettingsModel, connection: ConnectionModel) {
        self.settings = settings
        self.connection = connection
    }

    public enum State: Equatable {
        case offline
        case connecting
        case online(VisionModel)

        public var isOnline: Bool {
            switch self {
            case .online:
                return true
            default:
                return false
            }
        }
    }

    public enum Action: Sendable {
        case connect
        case goesOnline(VisionModel)
        case goesOffline
        case disconnect
        case objectDetectionStart
        case objectDetectionStop
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .connect:
                return Effect.run(operation: { send in
                    if let stream = try connection.camera?.requestCameraFeed() {
                        let model = VisionModel(with: stream)
                        await send(Action.goesOnline(model))
                    } else {
                        await send(Action.goesOffline)
                    }
                })

            case let .goesOnline(model):
                state = .online(model)
                return .none

            case .goesOffline:
                state = State.offline
                return .none

            case .disconnect:
                return Effect.run { send in
                    await send(.goesOffline)
                }

            case .objectDetectionStart:
                if case let .online(model) = state {
                    model.objectDetectionStart()
                }
                return .none

            case .objectDetectionStop:
                if case let .online(model) = state {
                    model.objectDetectionStop()
                }
                return .none
            }
        }
    }
}
