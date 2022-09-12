import Combine
import SwiftUI

extension SettingsView {
    class ViewModel: ObservableObject {
        @Published public var ip: String = ""
        @Published public var eyeColor: Color = .white
        @Published public var isValid: Bool = false
        @Published public var locale: String = "en"
        
        private let model: SettingsModel
        private var bag = Set<AnyCancellable>()
        private let regex = "^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$"
        
        init(_ model: SettingsModel) {
            self.model = model
            self.ip = model.ip
            self.eyeColor = model.eyeColor
            self.locale = model.locale
        }
        
        @MainActor func save() {
            model.ip = ip
            model.eyeColor = eyeColor
            model.locale = locale
        }
        
        func validate() {
            isValid = ip.range(of: regex, options: .regularExpression) != nil
        }
    }

}
