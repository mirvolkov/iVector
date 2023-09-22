import Combine
import Features
import SwiftUI

extension SettingsView {
    class ViewModel: ObservableObject {
        @Published public var vectorIP: String = ""
        @Published public var websocketIP: String = ""
        @Published public var eyeColor: Color = .white
        @Published public var isValid: Bool = false
        @Published public var locale: String = "en"
        @Published public var certPath: URL? = nil
        @Published public var guid: String? = nil
        
        private let model: SettingsModel
        private var bag = Set<AnyCancellable>()
        private let regex = "^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$"
        
        init(_ model: SettingsModel) {
            self.model = model
            self.vectorIP = model.vectorIP
            self.websocketIP = model.websocketIP
            self.eyeColor = model.eyeColor
            self.locale = model.locale
        }
        
        @MainActor func save() {
            model.vectorIP = vectorIP
            model.websocketIP = websocketIP
            model.eyeColor = eyeColor
            model.locale = locale
        }
        
        func validate() {
            isValid = vectorIP.range(of: regex, options: .regularExpression) != nil &&
                websocketIP.range(of: regex, options: .regularExpression) != nil
        }
    }
}
