import Foundation
import Features

struct Config {
    var device: EnvironmentDevice {
        guard let value: String = infoForKey("Device") else {
            return .mock
        }
        return .init(rawValue: value) ?? .mock
    }

    private func infoForKey<T>(_ key: String) -> T? {
        return (Bundle.main.infoDictionary?[key] as? T)
    }
}
