import Foundation

// TODOs
// Vision can use external camera as a source, internal camera or vision stream from vector
// Source can be interrupted, in this case we may need to reconnect (for external camera especially)

import ComposableArchitecture

public struct VisionFeature: ReducerProtocol {
    let settings: SettingsModel

    public init(settings: SettingsModel) {
        self.settings = settings
    }

    public enum State: Equatable {
        case offline
        case connecting
        case online
    }

    public enum Action {
        case connect
        case goesOnline
        case goesOffline
        case disconnect
    }

    public var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .connect:
                return Effect.run(operation: { send in
                    await send(Action.goesOnline)
                })

            case .goesOnline:
                return .none

            case .goesOffline:
                state = State.offline
                return .none

            case .disconnect:
                return .none
            }
        }
    }
}
