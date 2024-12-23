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
    @Published var items = SoundPlayer.all
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
