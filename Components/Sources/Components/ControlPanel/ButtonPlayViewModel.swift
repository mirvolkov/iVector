import Features
import SwiftUI

class ButtonPlayViewModel: ControlPanelButtonViewModel {
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var showAudioListPopover: Bool = false
    @Published var sounds = SoundPlayer.SoundName.allCases
    
    private let connection: ConnectionModel

    init(connection: ConnectionModel) {
        self.connection = connection
        self.primaryIcon = .init(systemName: "bell.badge")
        self.tintColor = .orange
    }

    func onClick() {
        showAudioListPopover = true
    }
    
    func onSelect(_ sound: SoundPlayer.SoundName) {
        showAudioListPopover = false
    }
}

extension SoundPlayer.SoundName: CustomStringConvertible {
    public var description: String {
        switch self {
        case .alarm:
            return "ALARM"
        case .cputer2:
            return "PC UP"
        }
    }
}
