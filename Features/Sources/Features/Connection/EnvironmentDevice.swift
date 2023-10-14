// swiftlint:disable:next file_header
import Foundation

public enum EnvironmentDevice: String {
    case mock
    case vector
    case pathfinder
}

public extension EnvironmentDevice {
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
            true
        #else
            false
        #endif
    }
}
