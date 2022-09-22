import Combine
import Features
import SwiftUI

class ButtonTTSViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var isLoading: Bool = false
    @Published var ttsAlert: Bool = false
    
    private let settings: SettingsModel
    private let connection: ConnectionModel
    private var bag = Set<AnyCancellable>()

    init(connection: ConnectionModel, settings: SettingsModel) {
        self.connection = connection
        self.settings = settings
        self.primaryIcon = .init(systemName: "text.bubble")
        self.tintColor = .orange
    }
    
    func onClick() {
        ttsAlert = true
    }
    
    func say(_ text: String) {
        Task.detached {
            try await self.connection.say(text: text)//, locale: Locale(identifier: self.settings.locale))
        }
    }
}
