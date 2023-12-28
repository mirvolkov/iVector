// swiftlint:disable:next file_header
import ComposableArchitecture
import Connection
import Foundation
import SocketIO
import SwiftBus

public struct VisionFeature: ReducerProtocol {
    public struct VisionObservation: AppHub.SocketMessage {
        public let label: String
        public let confidence: Float
        public let date: Date = .init()

        public init(label: String, confidence: Float) {
            self.label = label
            self.confidence = confidence
        }

        public func socketRepresentation() throws -> SocketData {
            ["label": label, "confidence": confidence, "timestamp": date.timeIntervalSince1970]
        }
    }

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
    }

    public func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .connect:
            state = .connecting
            return Effect.run(operation: { send in
                if let stream = try await connection.camera?.requestCameraFeed(
                    with: .init(rotation: settings.cameraROT, deviceID: settings.cameraID)
                ) {
                    let model = VisionModel(with: connection, stream: stream)
                    await send(Action.goesOnline(model))
                } else {
                    await send(Action.goesOffline)
                }
            })

        case let .goesOnline(model):
            state = .online(model)
            return .none

        case .goesOffline:
            state = .offline
            return .none

        case .disconnect:
            return Effect.run { send in
                await send(.goesOffline)
            }
        }
    }
}
