import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var ip: String = ""
    
    private let model: Settings
    private var bag = Set<AnyCancellable>()
    
    init(_ model: Settings) {
        self.model = model
        model
            .$ip
            .receive(on: RunLoop.main)
            .assign(to: \.ip, on: self)
            .store(in: &self.bag)
    }
    
    @MainActor func save() {
        self.model.setIP(self.ip)
    }
}
