import Features
import SwiftUI

class SettingsModel {
    @AppStorage("ip") var ip: String = .init()
    @AppStorage("eyeColor") var eyeColor: Color = .white
}
