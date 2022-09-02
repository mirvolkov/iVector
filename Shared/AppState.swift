import SwiftUI

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
    var vision: VisionModel = .init()
    var settings: Settings = .init()
}
