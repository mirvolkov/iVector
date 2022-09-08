import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var ip: String = ""
    @Published var eyeColor: Color = .white
    @Published var isValid: Bool = false
    
    private let model: SettingsModel
    private var bag = Set<AnyCancellable>()
    private let regex = "^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$"
    
    init(_ model: SettingsModel) {
        self.model = model
        self.ip = model.ip
        self.eyeColor = model.eyeColor
    }
    
    @MainActor func save() {
        model.ip = ip
        model.eyeColor = eyeColor
    }
    
    func validate() {
        isValid = ip.range(of: regex, options: .regularExpression) != nil
    }
}
