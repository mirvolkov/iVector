import SwiftUI

public final class SettingsModel: @unchecked Sendable {
    /// Vector's IP port
    @AppStorage("vectorPort")
    public var vectorPort: Int = 443
    /// Vector's IP address
    @AppStorage("vectorIP")
    public var vectorIP: String = "192.168.0.1"
    /// Eye color
    @AppStorage("eyeColor")
    public var eyeColor: Color = .white
    /// Locale used for text to speech generator
    @AppStorage("locale")
    public var locale: String = "en"
    /// Vector's IP port
    @AppStorage("websocketPort")
    public var websocketPort: Int = 10005
    /// Vector's IP address
    @AppStorage("websocketIP")
    public var websocketIP: String = "192.168.0.1"
    /// Camera UUID
    @AppStorage("cameraID")
    public var cameraID: String?
    /// Camera rotation angle
    @AppStorage("cameraROT")
    public var cameraROT: Int = 0

    public init() {}
}

extension SettingsModel: Equatable {
    public static func == (lhs: SettingsModel, rhs: SettingsModel) -> Bool {
        lhs.vectorIP == rhs.vectorIP
    }
}
