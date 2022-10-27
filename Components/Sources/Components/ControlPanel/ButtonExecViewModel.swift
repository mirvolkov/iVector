import SwiftUI
import Programmator

class ButtonExecViewModel: ControlPanelButtonViewModel, PickListPopoverCallback {
    @Published var disableSecondary: Bool = false
    @Published var disableTitle: Bool = false
    @Published var disableIcon: Bool = false
    @Published var enabled: Bool = true
    @Published var primaryIcon: Image?
    @Published var primaryTitle: String?
    @Published var secondaryTitle: String?
    @Published var tintColor: Color = .yellow
    @Published var showPrograms: Bool = false
    @Published var tag: CPViewModelTag? {
        didSet {
            enabled = tag != nil
        }
    }

    var items: [Program] {
        get async {
            await (try? AssemblerModel.programs) ?? []
        }
    }

    private let assembler: AssemblerModel

    init(assembler: AssemblerModel) {
        self.primaryIcon = .init(systemName: "command")
        self.assembler = assembler
    }

    func onClick() {
        showPrograms = true
    }

    func onItemSelected(item: Programmator.Program) {
        assembler.extend(with: item)
        showPrograms = false
    }
}
