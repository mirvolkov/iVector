import SwiftUI

public final class SettingsModel {
    /// Vector's IP port
    @AppStorage("port") public var port: Int = 443
    /// Vector's IP address
    @AppStorage("ip") public var ip: String = "192.168.0.1"
    /// Eye color
    @AppStorage("eyeColor") public var eyeColor: Color = .white
    /// Locale used for text to speech generator
    @AppStorage("locale") public var locale: String = "en"

    public init() {}
}

extension SettingsModel: Equatable {
    public static func == (lhs: SettingsModel, rhs: SettingsModel) -> Bool {
        lhs.ip == rhs.ip
    }
}
