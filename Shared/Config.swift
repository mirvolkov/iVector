import Foundation

struct Config {
    var useMocked: Bool {
        return infoForKey("IsMocked") == "True"
    }

    private func infoForKey<T>(_ key: String) -> T? {
        return (Bundle.main.infoDictionary?[key] as? T)
    }
}
