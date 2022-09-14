import Features
import SwiftUI

public class SettingsModel {
    /// Vector's IP port
    @AppStorage("port") var port: Int = 443
    /// Vector's IP address
    @AppStorage("ip") var ip: String = "192.168.0.1"
    /// Eye color
    @AppStorage("eyeColor") var eyeColor: Color = .white
    /// Locale used for text to speech generator
    @AppStorage("locale") var locale: String = "en"
    
    public init() {}
}
