import SwiftUI
import Components
import Features

enum VectorAppFeatureState {
    case vision
}

enum VectorAppConnState {
    case offline
    case online(VectorAppFeatureState)
}

struct AppState {
    public static var instance = AppState()
    public var state: VectorAppConnState = .offline
    
    var connection: ConnectionModel = .init()
    var settings: SettingsModel = .init()
    lazy var vision: VisionModel = .init(with: connection)
}
