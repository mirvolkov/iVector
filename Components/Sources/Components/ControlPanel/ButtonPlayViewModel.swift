import Features
import SwiftUI
import Programmator

class ButtonPlayViewModel: ControlPanelButtonViewModel, PickListPopoverCallback {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var showAudioListPopover: Bool = false
    @Published var items = SoundPlayer.SoundName.allCases
    @Published var tag: CPViewModelTag?

    private let assembler: AssemblerModel

    init(assembler: AssemblerModel) {
        self.assembler = assembler
        self.primaryIcon = .init(systemName: "bell.badge")
    }

    func onClick() {
        showAudioListPopover = true
    }
    
    func onItemSelected(item: SoundPlayer.SoundName) {
        showAudioListPopover = false
        assembler.extend(with: item)
    }
}

extension SoundPlayer.SoundName: CustomStringConvertible {
    public var description: String {
        switch self {
        case .alarm:
            return "ALARM"
        case .cputer1:
            return "CPUTER 1"
        case .cputer2:
            return "CPUTER 2"
        case .r2d21:
            return "R2D2 1"
        case .r2d22:
            return "R2D2 2"
        case .scream:
            return "SCREAM"
        case .ping:
            return "PING"
        case .pcup:
            return "PCUP"
        }
    }
}
