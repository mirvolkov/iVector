import SwiftUI
import Programmator

class Button0ViewModel: ControlPanelButtonViewModel {
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

    private let assembler: AssemblerModel

    init(assembler: AssemblerModel) {
        self.assembler = assembler
        self.primaryIcon = .init(systemName: "arrow.triangle.branch")
        self.primaryTitle = "0"
    }
}
