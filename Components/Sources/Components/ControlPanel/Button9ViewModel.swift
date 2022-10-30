import SwiftUI
import Programmator

class Button9ViewModel: ControlPanelButtonViewModel, TextFieldPopoverCallback {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .green
    @Published var tag: CPViewModelTag? {
        didSet {
            enabled = tag != nil
        }
    }
    @Published var showTextRequest: Bool = false

    private let assembler: AssemblerModel

    init(assembler: AssemblerModel) {
        self.assembler = assembler
        self.primaryIcon = .init(systemName: "arrow.down.right.square")
        self.primaryTitle = "9"
        self.secondaryTitle = L10n.listen
    }

    func onClick() {
        if tag is Extension.ConditionValue{
            showTextRequest = true
        }
    }

    func onTextChange(text: String) {
        assembler.extend(with: text)
        showTextRequest = false
    }
}
