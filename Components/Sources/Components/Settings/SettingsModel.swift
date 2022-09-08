import Features
import SwiftUI

public class SettingsModel {
    @AppStorage("port") var port: Int = 443
    @AppStorage("ip") var ip: String = "192.168.0.1"
    @AppStorage("eyeColor") var eyeColor: Color = .white
    @AppStorage("locale") var locale: String = "en"
    
    public init() {}
}
