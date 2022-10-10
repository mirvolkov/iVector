import Combine
import Features
import SwiftUI
import Programmator

class ButtonTTSViewModel: ControlPanelButtonViewModel, TextFieldPopoverCallback {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var isLoading: Bool = false
    @Published var ttsAlert: Bool = false
    @Published var tag: CPViewModelTag?

    private let assembler: AssemblerModel

    init(assembler: AssemblerModel) {
        self.assembler = assembler
        self.primaryIcon = .init(systemName: "text.bubble")
        self.tintColor = .orange
    }

    func onClick() {
        ttsAlert = true
    }

    @MainActor func onTextChange(text: String) {
        ttsAlert = false
        assembler.extend(with: text)
    }
}
