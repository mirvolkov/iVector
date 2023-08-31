import Foundation

struct Config {
    enum Device: String {
        case mock
        case vector
        case pathfinder
    }

    var device: Device {
        guard let value: String = infoForKey("Device") else {
            return .mock
        }
        return .init(rawValue: value) ?? .mock
    }

    private func infoForKey<T>(_ key: String) -> T? {
        return (Bundle.main.infoDictionary?[key] as? T)
    }
}
